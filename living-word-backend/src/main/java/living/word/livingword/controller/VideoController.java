package living.word.livingword.controller;

import jakarta.validation.Valid;
import living.word.livingword.entity.VideoCreateRequest;
import living.word.livingword.model.dto.VideoDto;
import living.word.livingword.service.VideoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/videos")
public class VideoController {

    @Autowired
    private VideoService videoService;

    // Add a new video link
    @PostMapping("/add")
    @PreAuthorize("hasAuthority('PERM_VIDEO_WRITE') or hasAuthority('PERM_ADMIN_ACCESS')")
    public ResponseEntity<?> addVideo(@Valid @RequestBody VideoCreateRequest videoRequest) {
        try {
            VideoDto savedVideo = videoService.addVideo(videoRequest);
            return new ResponseEntity<>(savedVideo, HttpStatus.CREATED);
        } catch (Exception e) {
            return new ResponseEntity<>("Error al añadir el video", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    // Get all videos
    @GetMapping
    @PreAuthorize("hasAuthority('PERM_VIDEO_READ') or hasAuthority('PERM_ADMIN_ACCESS')")
    public ResponseEntity<List<VideoDto>> getAllVideos() {
        List<VideoDto> videos = videoService.getAllVideos();
        return new ResponseEntity<>(videos, HttpStatus.OK);
    }
}