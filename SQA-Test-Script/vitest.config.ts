import { defineVitestConfig } from '@nuxt/test-utils/config'

export default defineVitestConfig({
  test: {
    environment: 'happy-dom',
    globals: true,
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html'],
      include: ['app/composables/useAuth.ts', 'app/composables/useDefaultRole.ts', 'app/utils/role.ts', 'app/stores/auth.ts'],
    }
  }
})
