import { describe, it, expect, beforeEach } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useAuthStore } from '../app/stores/auth'
import type { TAccountRole } from '../app/stores/auth'

describe('Auth Store (TC-AUTH-06)', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })

  it('[TC-AUTH-06] clearStore should clear token, roles, and currentRole to prevent sticking to previous session', () => {
    const store = useAuthStore()
    
    // Arrange: Set initial state
    const mockRole: TAccountRole = { id: 1, code: 'CANDIDATE', name: 'Candidate', isDefault: false }
    store.setToken('mock-token-123')
    store.setRoles([mockRole])
    store.setCurrentRole(mockRole)
    
    // Assert initial state
    expect(store.token).toBe('mock-token-123')
    expect(store.roles.length).toBe(1)
    expect(store.currentRole?.code).toBe('CANDIDATE')

    // Act: Call clearStore (simulating Logout action)
    store.clearStore()
    
    // Assert final state
    expect(store.token).toBe(null)
    expect(store.roles.length).toBe(0)
    expect(store.currentRole).toBe(undefined)
  })

  it('clearToken should only clear token and roles but keep other states consistent', () => {
    const store = useAuthStore()
    
    store.setToken('mock-token-456')
    store.clearToken()
    
    expect(store.token).toBe(null)
    expect(store.roles.length).toBe(0)
    expect(store.currentRole).toBe(null)
  })
})
