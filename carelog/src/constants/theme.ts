export const Colors = {
  primary:      '#1A6B8A',
  secondary:    '#2E9E6B',
  accent:       '#E67E22',
  error:        '#E53935',
  background:   '#F5F7FA',
  surface:      '#FFFFFF',
  border:       '#E0E0E0',
  textPrimary:  '#212121',
  textSecondary:'#757575',
  textDisabled: '#BDBDBD',
};

export const Spacing = {
  xs: 4, sm: 8, md: 16, lg: 24, xl: 32, xxl: 48,
};

export const BorderRadius = {
  sm: 6, md: 12, lg: 16, xl: 24, full: 999,
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
  card: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 4,
    elevation: 2,
  },
};
