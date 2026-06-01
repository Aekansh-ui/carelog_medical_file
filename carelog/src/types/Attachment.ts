export type AttachmentType = 'prescription' | 'medicine' | 'bill' | 'report';
export type MimeType = 'image/jpeg' | 'image/png' | 'application/pdf';

export interface Attachment {
  id: string;                       // UUID v4
  visit_id: string;
  type: AttachmentType;
  file_path: string;                // Absolute path in app document directory
  file_name: string;
  mime_type: MimeType;
  size_bytes: number;
  thumbnail_path?: string;          // Compressed thumbnail for images
  created_at: string;
  // Joined from visits + members tables (present on findByType/findAll results):
  member_name?: string;
  member_color?: string;
}

export type CreateAttachmentInput = Omit<Attachment, 'id' | 'created_at'>;

export const ATTACHMENT_LIMITS: Record<AttachmentType, { maxFiles: number; maxSizeBytes: number }> = {
  prescription: { maxFiles: 5,  maxSizeBytes: 10 * 1024 * 1024 },
  medicine:     { maxFiles: 10, maxSizeBytes: 10 * 1024 * 1024 },
  bill:         { maxFiles: 5,  maxSizeBytes: 10 * 1024 * 1024 },
  report:       { maxFiles: 10, maxSizeBytes: 20 * 1024 * 1024 },
};
