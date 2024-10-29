package living.word.livingword.controller;

import jakarta.validation.Valid;
import living.word.livingword.model.dto.NewsletterCreateRequest;
import living.word.livingword.model.dto.NewsletterDto;
import living.word.livingword.entity.Newsletter;
import living.word.livingword.exception.FileStorageException;
import living.word.livingword.exception.NewsletterNotFoundException;
import living.word.livingword.repository.NewsletterRepository;
import living.word.livingword.service.NewsletterService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/newsletters")
public class NewsletterController {

    @Autowired
    private NewsletterService newsletterService;
    @Autowired
    private NewsletterRepository newsletterRepository;

    // Create a new newsletter
    @PostMapping("/create")
    @PreAuthorize("hasAuthority('PERM_ADMIN_ACCESS') or hasAuthority('PERM_NEWSLETTER_WRITE')")
    public ResponseEntity<?> createNewsletter(
            @Valid @ModelAttribute NewsletterCreateRequest request,
            @RequestParam("image") MultipartFile imageFile) {
        try {
            Newsletter newsletter = newsletterService.createNewsletter(request.getTitle(), request.getContent(), imageFile);
            return new ResponseEntity<>(newsletterService.convertToDto(newsletter), HttpStatus.CREATED);
        } catch (FileStorageException e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        } catch (Exception e) {
            return new ResponseEntity<>("Internal server error", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    // Get all newsletters
    @GetMapping
    @PreAuthorize("hasAuthority('PERM_ADMIN_ACCESS') or hasAuthority('PERM_NEWSLETTER_READ')")
    public ResponseEntity<List<NewsletterDto>> getAllNewsletters(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "desc") String sortDirection) { // New param for sort direction

        // Determine sort direction
        Sort.Direction direction = "asc".equalsIgnoreCase(sortDirection) ? Sort.Direction.ASC : Sort.Direction.DESC;

        // Create PageRequest with sorting by publicationDate
        PageRequest pageRequest = PageRequest.of(page, size, Sort.by(direction, "publicationDate"));

        List<Newsletter> newsletters = newsletterRepository.findAll(pageRequest).getContent();
        List<NewsletterDto> newsletterDtos = newsletters.stream()
                .map(newsletterService::convertToDto)
                .collect(Collectors.toList());

        return new ResponseEntity<>(newsletterDtos, HttpStatus.OK);
    }


    // Get a specific newsletter by id
    @GetMapping("/{id}")
    @PreAuthorize("hasAuthority('PERM_ADMIN_ACCESS') or hasAuthority('PERM_NEWSLETTER_READ')")
    public ResponseEntity<?> getNewsletterById(@PathVariable Long id) {
        try {
            Newsletter newsletter = newsletterService.getNewsletterById(id)
                    .orElseThrow(() -> new NewsletterNotFoundException("Newsletter with id " + id + " not found."));
            return new ResponseEntity<>(newsletterService.convertToDto(newsletter), HttpStatus.OK);
        } catch (NewsletterNotFoundException e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.NOT_FOUND);
        }
    }

    // Get newsletter image
    @GetMapping("/images/{filename}")
    @PreAuthorize("hasAuthority('PERM_ADMIN_ACCESS') or hasAuthority('PERM_NEWSLETTER_READ')")
    public ResponseEntity<?> getNewsletterImage(@PathVariable String filename) {
        try {
            byte[] image = newsletterService.getNewsletterImage(filename);
            HttpHeaders headers = new HttpHeaders();
            headers.set(HttpHeaders.CONTENT_TYPE, Files.probeContentType(Paths.get(filename)));
            return new ResponseEntity<>(image, headers, HttpStatus.OK);
        } catch (FileStorageException e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.NOT_FOUND);
        } catch (IOException e) {
            return new ResponseEntity<>("Error determining content type", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    // Delete a newsletter
    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('PERM_ADMIN_ACCESS') or hasAuthority('PERM_NEWSLETTER_DELETE')")
    public ResponseEntity<?> deleteNewsletter(@PathVariable Long id) {
        try {
            newsletterService.deleteNewsletter(id);
            return new ResponseEntity<>(HttpStatus.NO_CONTENT);
        } catch (NewsletterNotFoundException e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.NOT_FOUND);
        } catch (FileStorageException e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}