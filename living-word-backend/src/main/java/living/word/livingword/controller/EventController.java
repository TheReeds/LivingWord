package living.word.livingword.controller;

import living.word.livingword.model.dto.EventCreateRequest;
import living.word.livingword.model.dto.EventDto;
import living.word.livingword.service.EventService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/events")
public class EventController {

    @Autowired
    private EventService eventService;

    // Endpoint para crear un evento
    @PostMapping("/create")
    @PreAuthorize("hasAnyAuthority('EVENT_WRITE', 'PERM_ADMIN_ACCESS')") // Asegurarse de que el usuario sea un líder de departamento
    public ResponseEntity<EventDto> createEvent(@RequestBody EventCreateRequest eventRequest) {
        EventDto createdEvent = eventService.createEvent(eventRequest);
        return ResponseEntity.ok(createdEvent);
    }

    // Endpoint para editar un evento
    @PutMapping("/edit/{eventId}")
    @PreAuthorize("hasAnyAuthority('EVENT_EDIT', 'PERM_ADMIN_ACCESS')") // Solo roles nivel 3 y 4 pueden editar
    public ResponseEntity<EventDto> editEvent(@PathVariable Long eventId, @RequestBody EventDto eventDto) {
        EventDto updatedEvent = eventService.editEvent(eventId, eventDto);
        return ResponseEntity.ok(updatedEvent);
    }
}