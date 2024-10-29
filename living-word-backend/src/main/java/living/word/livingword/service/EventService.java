package living.word.livingword.service;

import living.word.livingword.model.dto.EventCreateRequest;
import living.word.livingword.model.dto.EventDto;
import living.word.livingword.entity.Event;
import living.word.livingword.entity.Ministry;
import living.word.livingword.entity.User;
import living.word.livingword.exception.AccessDeniedException;
import living.word.livingword.exception.EventNotFoundException;
import living.word.livingword.repository.AppUserRepository;
import living.word.livingword.repository.EventRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class EventService {

    @Autowired
    private EventRepository eventRepository;

    @Autowired
    private AppUserRepository userRepository;

    @Autowired
    private NotificationService notificationService;

    // Obtener el usuario autenticado
    private User getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof User) {
            return (User) authentication.getPrincipal();
        }
        throw new RuntimeException("No se encontró un usuario autenticado");
    }

    // Crear un evento solo para los usuarios del ministerio del líder
    @Transactional
    public EventDto createEvent(EventCreateRequest eventRequest) {
        User currentUser = getCurrentUser();

        Ministry ministry = currentUser.getMinistry();  // Obtener el ministerio del líder

        Event event = new Event();
        event.setTitle(eventRequest.getTitle());
        event.setDescription(eventRequest.getDescription());
        event.setEventDate(eventRequest.getEventDate());
        event.setCreatedBy(currentUser);
        event.setMinistry(ministry);

        Event savedEvent = eventRepository.save(event);

        // Notificar a los usuarios del ministerio
        List<User> ministryUsers = userRepository.findByMinistry(ministry);
        notificationService.sendEventNotification(savedEvent, ministryUsers);

        return convertToDto(savedEvent);
    }

    // Editar evento (niveles 3 y 4)
    @Transactional
    public EventDto editEvent(Long eventId, EventDto eventDto) {
        User currentUser = getCurrentUser();

        // Validar si el usuario tiene nivel 3 o 4
        if (currentUser.getRole().getLevel() < 3) { // Suponiendo que Role enum tiene un método getLevel()
            throw new AccessDeniedException("No tienes permiso para editar eventos.");
        }

        Event event = eventRepository.findById(eventId)
                .orElseThrow(() -> new EventNotFoundException("Evento no encontrado"));

        event.setTitle(eventDto.getTitle());
        event.setDescription(eventDto.getDescription());
        event.setEventDate(eventDto.getEventDate());

        Event updatedEvent = eventRepository.save(event);
        return convertToDto(updatedEvent);
    }

    // Convertir entidad a DTO
    private EventDto convertToDto(Event event) {
        EventDto dto = new EventDto();
        dto.setId(event.getId());
        dto.setTitle(event.getTitle());
        dto.setDescription(event.getDescription());
        dto.setEventDate(event.getEventDate());
        dto.setCreatedByUsername(event.getCreatedBy().getName()); // O getUsername() según tu implementación
        return dto;
    }
}