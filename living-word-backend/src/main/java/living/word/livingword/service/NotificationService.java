package living.word.livingword.service;

import com.google.firebase.messaging.*;
import living.word.livingword.entity.*;
import living.word.livingword.repository.AppUserRepository;
import living.word.livingword.repository.DeviceTokenRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class NotificationService {

    @Autowired
    private AppUserRepository appUserRepository;
    @Autowired
    private DeviceTokenRepository deviceTokenRepository;
    @Autowired
    private FirebaseService firebaseService;
    @Autowired
    private RoleService roleService;

    // Notificar a los usuarios de un evento
    public void notifyUsers(Event event) {
        firebaseService.notifyUsersOfEvent(event);
    }
    // Enviar notificación al inicio de un sermo
    public void sendSermonStartNotification(Sermon sermon) {
        String title = "Inicio del Culto";
        String body = "El culto ha comenzado: " + sermon.getTitle();

        List<User> allUsers = appUserRepository.findAll(); // Puedes filtrar por ministerio si es necesario
        List<String> tokens = allUsers.stream()
                .flatMap(user -> user.getDeviceTokens().stream())
                .map(dt -> dt.getToken())
                .collect(Collectors.toList());

        firebaseService.sendNotification(tokens, title, body);
    }
    // Enviar notificación al finalizar un sermo para feedback
    public void sendSermonEndNotification(Sermon sermon) {
        String title = "Feedback de Asistencia al Culto";
        String body = "¿Asististe al culto de hoy: " + sermon.getTitle() + "?";

        List<User> allUsers = appUserRepository.findAll(); // Puedes filtrar por ministerio si es necesario
        List<String> tokens = allUsers.stream()
                .flatMap(user -> user.getDeviceTokens().stream())
                .map(dt -> dt.getToken())
                .collect(Collectors.toList());

        firebaseService.sendNotification(tokens, title, body);
    }
    // Notificar a los administradores sobre una ausencia
    public void notifyAdminAbsence(User user, Sermon sermon) {
        String title = "Ausencia en el Culto";
        String body = "El usuario " + user.getName() + " no asistió al culto de hoy: " + sermon.getTitle();

        // Obtener usuarios con rol ADMINISTRATOR
        Role adminRole = roleService.getRoleByName("ADMINISTRATOR")
                .orElseThrow(() -> new IllegalStateException("ADMINISTRATOR role not found"));
        List<User> admins = appUserRepository.findByRole(adminRole);

        List<String> tokens = admins.stream()
                .flatMap(admin -> admin.getDeviceTokens().stream())
                .map(dt -> dt.getToken())
                .collect(Collectors.toList());

        firebaseService.sendNotification(tokens, title, body);
    }

    // Notify all users about a new newsletter
    public void sendNewsletterNotification(Newsletter newsletter) {
        List<User> users = appUserRepository.findAll();
        for (User user : users) {
            sendNotification(user, "New Newsletter Published", "Check out our new newsletter: " + newsletter.getTitle());
        }
    }

    // Notify all users about a new event
    public void sendEventNotification(Event event, List<User> recipients) {
        for (User user : recipients) {
            List<String> tokens = deviceTokenRepository.findByUser(user)
                    .stream()
                    .map(deviceToken -> deviceToken.getToken())
                    .toList();

            if (!tokens.isEmpty()) {
                // Usa MulticastMessage en lugar de Message
                MulticastMessage message = MulticastMessage.builder()
                        .setNotification(Notification.builder()
                                .setTitle("Nuevo Evento: " + event.getTitle())
                                .setBody(event.getDescription())
                                .build())
                        .addAllTokens(tokens) // MulticastMessage acepta varios tokens
                        .build();

                try {
                    BatchResponse response = FirebaseMessaging.getInstance().sendMulticast(message);
                    System.out.println("Notificaciones enviadas: " + response.getSuccessCount());
                } catch (FirebaseMessagingException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    // Notify a specific user about a prayer request update
    public void sendPrayerRequestNotification(User user, PrayerRequest prayerRequest) {
        sendNotification(user, "Prayer Request Update", "A user is praying for your request: " + prayerRequest.getUser().getPrayerRequests());
    }

    // Notify a specific user (general method)
    private void sendNotification(User user, String title, String message) {
        // Here you would implement the logic to send the notification.
        // This could be using Firebase Cloud Messaging (FCM), email, or another service.
        System.out.println("Sending notification to " + user.getEmail() + ": " + title + " - " + message);
    }
}