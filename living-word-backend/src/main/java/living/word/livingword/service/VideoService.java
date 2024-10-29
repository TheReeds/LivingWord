package living.word.livingword.service;
import jakarta.transaction.Transactional;
import living.word.livingword.entity.User;
import living.word.livingword.entity.Video;
import living.word.livingword.entity.VideoCreateRequest;
import living.word.livingword.model.dto.VideoDto;
import living.word.livingword.repository.VideoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class VideoService {

    @Autowired
    private VideoRepository videoRepository;

    // Get the authenticated user
    private User getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof User) {
            return (User) authentication.getPrincipal();
        }
        throw new RuntimeException("No authenticated user found");
    }

    // Add a new video
    @Transactional
    public VideoDto addVideo(VideoCreateRequest videoRequest) {
        User currentUser = getCurrentUser();

        Video video = new Video();
        video.setTitle(videoRequest.getTitle());
        video.setYoutubeUrl(videoRequest.getYoutubeUrl());
        video.setUploadedBy(currentUser); // Relacionar el usuario con el video

        Video savedVideo = videoRepository.save(video);

        return convertToDto(savedVideo);
    }
    // Convert Video entity to VideoDto
    public VideoDto convertToDto(Video video) {
        VideoDto dto = new VideoDto();
        dto.setId(video.getId());
        dto.setTitle(video.getTitle());
        dto.setYoutubeUrl(video.getYoutubeUrl());

        // Asignar el username si el usuario no es nulo
        if (video.getUploadedBy() != null) {
            dto.setUploadedByUsername(video.getUploadedBy().getUsername());
        } else {
            dto.setUploadedByUsername("Unknown");
        }

        return dto;
    }

    // Get all videos
    public List<VideoDto> getAllVideos() {
        List<Video> videos = videoRepository.findAll();
        return videos.stream()
                .map(this::convertToDto)  // Convert each Video entity to a VideoDto
                .toList();
    }
}