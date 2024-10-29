package living.word.livingword.entity;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class VideoCreateRequest {

    @NotBlank(message = "Title is required")
    private String title;

    @NotBlank(message = "YouTube URL is required")
    private String youtubeUrl;

}
