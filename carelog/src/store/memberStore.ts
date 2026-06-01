import { create } from 'zustand';
import { Member, CreateMemberInput, UpdateMemberInput, FamilySummary } from '@src/types/Member';
import { membersRepository } from '@src/db/membersRepository';
import { MEMBER_COLORS } from '@src/constants/members';

interface MemberState {
  members: Member[];
  summary: FamilySummary | null;
  loadMembers: () => void;
  loadSummary: () => void;
  // color is auto-assigned — callers supply everything except color
  createMember: (input: Omit<CreateMemberInput, 'color'>) => Member;
  updateMember: (id: string, input: UpdateMemberInput) => void;
  deleteMember: (id: string) => void;
  getMember: (id: string) => Member | undefined;
}

export const useMemberStore = create<MemberState>((set, get) => ({
  members: [],
  summary: null,

  loadMembers: () => set({ members: membersRepository.findAllWithStats() }),

  loadSummary: () => set({ summary: membersRepository.getFamilySummary() }),

  createMember: (input) => {
    const color = MEMBER_COLORS[get().members.length % MEMBER_COLORS.length];
    const member = membersRepository.create({ ...input, color });
    get().loadMembers();
    return member;
  },

  updateMember: (id, input) => {
    membersRepository.update(id, input);
    get().loadMembers();
  },

  deleteMember: (id) => {
    membersRepository.delete(id);
    get().loadMembers();
    get().loadSummary();
  },

  getMember: (id) => get().members.find(m => m.id === id),
}));
