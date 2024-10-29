package living.word.livingword.model.dto;

import lombok.Data;

@Data
public class VideoDto {
    private Long id;
    private String title;
    private String youtubeUrl;
    private String uploadedByUsername;
}
