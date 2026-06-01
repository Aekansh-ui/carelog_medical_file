export const Colors = {
  primary:      '#1A6B8A',
  secondary:    '#2E9E6B',
  accent:       '#E67E22',
  error:        '#E53935',
  background:   '#F4F6FA',
  surface:      '#FFFFFF',
  // Hairline border — kept very light so cards read as soft, modern surfaces
  // rather than boxed-in wireframes. Use borderStrong for true dividers.
  border:       '#ECEFF3',
  borderStrong: '#DFE3E9',
  textPrimary:  '#1B2330',
  textSecondary:'#6B7280',
  textDisabled: '#B4BBC6',
};

export const Spacing = {
  xs: 4, sm: 8, md: 16, lg: 24, xl: 32, xxl: 48,
};

export const BorderRadius = {
  sm: 10, md: 16, lg: 20, xl: 28, full: 999,
};

export const Typography = {
  h1:      { fontSize: 24, fontWeight: '700' as const, color: Colors.textPrimary },
  h2:      { fontSize: 20, fontWeight: '600' as const, color: Colors.textPrimary },
  h3:      { fontSize: 16, fontWeight: '600' as const, color: Colors.textPrimary },
  body:    { fontSize: 14, fontWeight: '400' as const, color: Colors.textPrimary },
  caption: { fontSize: 12, fontWeight: '400' as const, color: Colors.textSecondary },
  label:   { fontSize: 12, fontWeight: '500' as const, color: Colors.textSecondary },
};

export const Shadow = {
  // Subtle lift for inline rows / chips
  sm: {
    shadowColor: '#101828',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 3,
    elevation: 1,
  },
  // Default soft, diffuse card shadow — the modern "floating surface" look
  card: {
    shadowColor: '#101828',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.07,
    shadowRadius: 12,
    elevation: 3,
  },
  // Pronounced elevation for sheets / FAB / modals
  lg: {
    shadowColor: '#101828',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.12,
    shadowRadius: 20,
    elevation: 8,
  },
};
