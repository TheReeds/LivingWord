package living.word.livingword.service;
import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.messaging.*;
import jakarta.annotation.PostConstruct;
import living.word.livingword.entity.User;
import living.word.livingword.entity.Event;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class FirebaseService {

    @Value("${firebase.config.path}")
    private String firebaseConfigPath;

    @PostConstruct
    public void initialize() {
        try {
            FileInputStream serviceAccount = new FileInputStream(firebaseConfigPath);

            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                    .build();

            if (FirebaseApp.getApps().isEmpty()) {
                FirebaseApp.initializeApp(options);
            }
        } catch (IOException e) {
            throw new RuntimeException("Failed to initialize Firebase", e);
        }
    }

    // Enviar notificación a una lista de usuarios
    public void sendNotificationToUsers(List<User> users, String title, String body) {
        for(User user : users){
            sendNotification(user.getDeviceTokens().stream().map(dt -> dt.getToken()).collect(Collectors.toList()), title, body);
        }
    }

    // Enviar notificación a una lista de tokens
    public void sendNotification(List<String> tokens, String title, String body) {
        if(tokens.isEmpty()) return;

        Notification notification = Notification.builder()
                .setTitle(title)
                .setBody(body)
                .build();

        MulticastMessage message = MulticastMessage.builder()
                .addAllTokens(tokens)
                .setNotification(notification)
                .build();

        try {
            BatchResponse response = FirebaseMessaging.getInstance().sendMulticast(message);
            System.out.println("Successfully sent message: " + response.getSuccessCount());
        } catch (FirebaseMessagingException e) {
            e.printStackTrace();
        }
    }

    // Enviar notificación para un evento específico
    public void notifyUsersOfEvent(Event event) {
        List<User> ministryUsers = event.getMinistry().getUsers(); // Asegúrate de que la relación esté cargada
        sendNotificationToUsers(ministryUsers, "Nuevo Evento: " + event.getTitle(), event.getDescription());
    }
}