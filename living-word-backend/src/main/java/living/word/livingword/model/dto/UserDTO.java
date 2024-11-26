package living.word.livingword.model.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class UserDTO {
    private Long id;
    private String name;
    private String lastname;
    private String email;
    private String phone;
    private String ministry;
    private String address;
    private String gender;
    private String maritalstatus;
    private String role;
    private String photoUrl;
}