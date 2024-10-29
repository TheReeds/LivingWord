package living.word.livingword.controller;

import jakarta.validation.Valid;
import living.word.livingword.model.dto.DeviceTokenRequest;
import living.word.livingword.entity.User;
import living.word.livingword.service.DeviceTokenService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/device-tokens")
public class DeviceTokenController {

    @Autowired
    private DeviceTokenService deviceTokenService;

    // Endpoint para añadir un nuevo token de dispositivo
    @PostMapping("/add")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<?> addDeviceToken(@Valid @RequestBody DeviceTokenRequest deviceTokenRequest) {
        try {
            User currentUser = getCurrentUser();
            deviceTokenService.addDeviceToken(currentUser, deviceTokenRequest.getToken());
            return new ResponseEntity<>("Token agregado correctamente", HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>("Error al agregar el token", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    // Endpoint para eliminar un token de dispositivo
    @DeleteMapping("/remove")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<?> removeDeviceToken(@RequestParam String token) {
        try {
            deviceTokenService.removeDeviceToken(token);
            return new ResponseEntity<>("Token eliminado correctamente", HttpStatus.NO_CONTENT);
        } catch (Exception e) {
            return new ResponseEntity<>("Error al eliminar el token", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    private User getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof User) {
            return (User) authentication.getPrincipal();
        }
        throw new RuntimeException("No se encontró un usuario autenticado");
    }
}