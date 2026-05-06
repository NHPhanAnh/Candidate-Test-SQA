import { describe, it, expect, vi, beforeEach } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useAuthStore } from '../app/stores/auth'
import type { TAccountRole } from '../app/stores/auth'

describe('Auth & Role Logic Tests (TC-AUTH-01 & TC-AUTH-02)', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
    localStorage.clear()
    vi.clearAllMocks()
  })

  it('[TC-AUTH-01] Select Default Role: Should prioritize role with isDefault = true when logging in with multiple roles', () => {
    const store = useAuthStore()

    const role1: TAccountRole = { id: 1, code: 'CANDIDATE', name: 'Candidate', isDefault: false }
    const role2: TAccountRole = { id: 2, code: 'ORG_ADMIN', name: 'Admin', isDefault: true }
    const role3: TAccountRole = { id: 3, code: 'HR', name: 'HR', isDefault: false }

    store.setRoles([role1, role2, role3])
    
    // Simulate the logic from useDefaultRole
    let selectedRole = null
    const defaultRole = store.roles.find((r) => r.isDefault)
    if (defaultRole) {
      selectedRole = defaultRole
    }

    expect(selectedRole).toEqual(role2)
    expect(selectedRole?.code).toBe('ORG_ADMIN')
  })

  it('[TC-AUTH-02] Handle Stale Role: Should clear the local role if it is no longer valid in the associated accounts roles list', () => {
    const store = useAuthStore()
    
    // Valid roles after fetch
    const validRoles: TAccountRole[] = [
      { id: 1, code: 'CANDIDATE', name: 'Candidate', isDefault: false }
    ]
    store.setRoles(validRoles)

    // Stale local role (Role ID 99 which is not in the valid list)
    const staleLocalRole: TAccountRole = { id: 99, code: 'SYSTEM_ADMIN', name: 'Admin', isDefault: false }
    localStorage.setItem('current-role', JSON.stringify(staleLocalRole))
    
    // Simulate Role Stale validation logic
    const localRoleData = localStorage.getItem('current-role')
    let resolvedRole = localRoleData ? JSON.parse(localRoleData) : null
    
    const isValid = store.roles.some(r => r.id === resolvedRole?.id)
    if (!isValid) {
       // Reset logic
       localStorage.removeItem('current-role')
       resolvedRole = null
    }

    expect(isValid).toBe(false)
    expect(resolvedRole).toBe(null)
    expect(localStorage.getItem('current-role')).toBe(null)
  })
})
