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
  loadVisitsBySpeciality: (bodyPartId: string, specialityId: string) => void;
  loadVisitById: (id: string) => void;
  createVisit: (input: CreateVisitInput) => Visit;
  updateVisit: (id: string, input: UpdateVisitInput) => void;
  deleteVisit: (id: string) => void;
  searchVisits: (query: string) => void;
  clearSearch: () => void;
  getSpecialityCount: (specialityId: string) => number;
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

  loadVisitsBySpeciality: (bodyPartId, specialityId) => {
    set({ isLoading: true });
    const visits = visitsRepository.findBySpeciality(bodyPartId, specialityId);
    set({ currentSpecialityVisits: visits, isLoading: false });
  },

  loadVisitById: (id) => {
    const visit = visitsRepository.findById(id);
    set({ selectedVisit: visit });
  },

  createVisit: (input) => {
    const visit = visitsRepository.create(input);
    get().loadRecentVisits();
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

  getAutocompleteDoctors: (partial) =>
    visitsRepository.getAutocompleteDoctors(partial),

  getAutocompleteClinics: (partial) =>
    visitsRepository.getAutocompleteClinics(partial),
}));
