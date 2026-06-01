import { create } from 'zustand';
import { Visit, CreateVisitInput, UpdateVisitInput } from '@src/types/Visit';
import { visitsRepository } from '@src/db/visitsRepository';

interface VisitsState {
  recentVisits: Visit[];
  currentSpecialityVisits: Visit[];
  selectedVisit: Visit | null;
  searchResults: Visit[];
  isLoading: boolean;

  loadRecentVisits: () => void;
  loadRecentVisitsForMember: (memberId: string) => void;
  // memberId is optional for backward compat; when provided uses the member-scoped query
  loadVisitsBySpeciality: (bodyPartId: string, specialityId: string, memberId?: string) => void;
  loadVisitById: (id: string) => void;
  createVisit: (input: CreateVisitInput) => Visit;
  updateVisit: (id: string, input: UpdateVisitInput) => void;
  deleteVisit: (id: string) => void;
  searchVisits: (query: string) => void;
  clearSearch: () => void;
  getSpecialityCount: (specialityId: string) => number;
  getSpecialityCountForMember: (memberId: string, specialityId: string) => number;
  getAutocompleteDoctors: (partial: string) => string[];
  getAutocompleteClinics: (partial: string) => string[];
}

export const useVisitsStore = create<VisitsState>((set, get) => ({
  recentVisits: [],
  currentSpecialityVisits: [],
  selectedVisit: null,
  searchResults: [],
  isLoading: false,

  loadRecentVisits: () => {
    const visits = visitsRepository.findRecent(5);
    set({ recentVisits: visits });
  },

  loadRecentVisitsForMember: (memberId) => {
    const visits = visitsRepository.findRecentByMember(memberId, 5);
    set({ recentVisits: visits });
  },

  loadVisitsBySpeciality: (bodyPartId, specialityId, memberId) => {
    set({ isLoading: true });
    const visits = memberId
      ? visitsRepository.findBySpecialityForMember(memberId, bodyPartId, specialityId)
      : visitsRepository.findBySpeciality(bodyPartId, specialityId);
    set({ currentSpecialityVisits: visits, isLoading: false });
  },

  loadVisitById: (id) => {
    const visit = visitsRepository.findById(id);
    set({ selectedVisit: visit });
  },

  createVisit: (input) => {
    const visit = visitsRepository.create(input);
    // Refresh the member-scoped recent list so Member Home updates immediately.
    // Family Home reloads summary via useFocusEffect on next focus — no store cycle needed.
    get().loadRecentVisitsForMember(input.member_id);
    return visit;
  },

  updateVisit: (id, input) => {
    visitsRepository.update(id, input);
    get().loadVisitById(id);
  },

  deleteVisit: (id) => {
    visitsRepository.delete(id);
    get().loadRecentVisits();
    set({ selectedVisit: null });
  },

  searchVisits: (query) => {
    if (!query.trim()) { set({ searchResults: [] }); return; }
    const results = visitsRepository.search(query);
    set({ searchResults: results });
  },

  clearSearch: () => set({ searchResults: [] }),

  getSpecialityCount: (specialityId) =>
    visitsRepository.countBySpeciality(specialityId),

  getSpecialityCountForMember: (memberId, specialityId) =>
    visitsRepository.countBySpecialityForMember(memberId, specialityId),

  getAutocompleteDoctors: (partial) =>
    visitsRepository.getAutocompleteDoctors(partial),

  getAutocompleteClinics: (partial) =>
    visitsRepository.getAutocompleteClinics(partial),
}));
