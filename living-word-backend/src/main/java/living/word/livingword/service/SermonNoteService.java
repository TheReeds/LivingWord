package living.word.livingword.service;

import living.word.livingword.entity.SermonNote;
import living.word.livingword.repository.SermonNoteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class SermonNoteService {

    @Autowired
    private SermonNoteRepository sermonNoteRepository;

    // Add or update a sermon note
    public SermonNote addOrUpdateSermonNote(SermonNote sermonNote) {
        return sermonNoteRepository.save(sermonNote);
    }

    // Get all sermon notes
    public List<SermonNote> getAllSermonNotes() {
        return sermonNoteRepository.findAll();
    }
}
