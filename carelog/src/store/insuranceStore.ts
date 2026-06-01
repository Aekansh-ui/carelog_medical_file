import { create } from 'zustand';
import {
  InsurancePolicy,
  CreateInsuranceInput,
  UpdateInsuranceInput,
} from '@src/types/Insurance';
import { insuranceRepository } from '@src/db/insuranceRepository';

interface InsuranceState {
  // Policies for the member currently being viewed.
  policies: InsurancePolicy[];
  currentMemberId: string | null;

  loadForMember: (memberId: string) => void;
  createPolicy: (input: CreateInsuranceInput) => InsurancePolicy;
  updatePolicy: (id: string, input: UpdateInsuranceInput) => void;
  // Deletes the policy + its document rows; returns the file paths to remove from disk.
  deletePolicy: (id: string) => { filePath: string; thumbnailPath?: string }[];
}

export const useInsuranceStore = create<InsuranceState>((set, get) => ({
  policies: [],
  currentMemberId: null,

  loadForMember: (memberId) => {
    set({
      policies: insuranceRepository.findByMember(memberId),
      currentMemberId: memberId,
    });
  },

  createPolicy: (input) => {
    const policy = insuranceRepository.create(input);
    if (get().currentMemberId === input.member_id) {
      get().loadForMember(input.member_id);
    }
    return policy;
  },

  updatePolicy: (id, input) => {
    insuranceRepository.update(id, input);
    const memberId = get().currentMemberId;
    if (memberId) get().loadForMember(memberId);
  },

  deletePolicy: (id) => {
    const removedFiles = insuranceRepository.delete(id);
    const memberId = get().currentMemberId;
    if (memberId) get().loadForMember(memberId);
    return removedFiles;
  },
}));
