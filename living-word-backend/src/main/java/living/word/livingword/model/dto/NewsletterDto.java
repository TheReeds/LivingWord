package living.word.livingword.model.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class NewsletterDto {
    private Long id;
    private String title;
    private String content;
    private String imageUrl;
    private LocalDateTime publicationDate;
    private String uploadedByUsername;
}
