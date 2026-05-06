/**
 * File test: authStore.test.ts
 * File nguồn được kiểm thử: app/stores/auth.ts
 * Mô tả: Kiểm tra logic quản lý trạng thái trong Pinia Store cho Auth,
 *        cụ thể là các luồng đăng xuất và dọn dẹp token.
 *
 * Các Test Case trong file này:
 *   - TC-AUTH-08: Kiểm tra clearStore() dọn sạch toàn bộ trạng thái khi đăng xuất
 *   - TC-AUTH-09: Kiểm tra clearToken() chỉ xóa token và roles
 *
 * Công cụ sử dụng:
 *   - Vitest (test runner)
 *   - Pinia (store ảo trong bộ nhớ, không gọi API hay localStorage thật)
 */

import { describe, it, expect, beforeEach } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useAuthStore } from '../app/stores/auth'
import type { TAccountRole } from '../app/stores/auth'

describe('Auth Store — Quản lý trạng thái & Đăng xuất', () => {

  // Khởi tạo lại Pinia trước mỗi test để tránh trạng thái bị rò rỉ giữa các test
  beforeEach(() => {
    setActivePinia(createPinia())
  })

  /**
   * TC-AUTH-08
   * Mục tiêu  : Gọi clearStore() phải xóa sạch toàn bộ trạng thái auth (token, roles, currentRole)
   *             để đảm bảo không dính phiên đăng nhập cũ sau khi logout.
   * Đầu vào   : Store đang chứa token="mock-token-123", roles.length=1, currentRole.code="CANDIDATE"
   * Kết quả   : token=null, roles=[], currentRole=undefined
   * Loại test : Happy path
   */
  it('[TC-AUTH-08] clearStore() phải reset token, roles và currentRole về trạng thái ban đầu', () => {
    const store = useAuthStore()

    // --- ARRANGE: Nạp dữ liệu giả lập trạng thái người dùng đã đăng nhập ---
    const mockRole: TAccountRole = { id: 1, code: 'CANDIDATE', name: 'Candidate', isDefault: false }
    store.setToken('mock-token-123')
    store.setRoles([mockRole])
    store.setCurrentRole(mockRole)

    // Xác nhận store đang ở trạng thái đã đăng nhập trước khi test dọn dẹp
    expect(store.token).toBe('mock-token-123')
    expect(store.roles.length).toBe(1)
    expect(store.currentRole?.code).toBe('CANDIDATE')

    // --- ACT: Giả lập hành động đăng xuất bằng cách gọi clearStore ---
    store.clearStore()

    // --- ASSERT: Tất cả trạng thái phải được xóa sạch ---
    expect(store.token).toBe(null)
    expect(store.roles.length).toBe(0)
    expect(store.currentRole).toBe(undefined)
  })

  /**
   * TC-AUTH-09
   * Mục tiêu  : Gọi clearToken() chỉ xóa token và roles, không ảnh hưởng các trạng thái khác.
   * Đầu vào   : Store đang chứa token="mock-token-456"
   * Kết quả   : token=null, roles=[], currentRole=null
   * Loại test : Happy path
   */
  it('[TC-AUTH-09] clearToken() phải xóa token và làm rỗng danh sách roles', () => {
    const store = useAuthStore()

    // --- ARRANGE: Đặt một token hợp lệ vào store ---
    store.setToken('mock-token-456')

    // --- ACT: Xóa token (dọn dẹp một phần, ví dụ khi refresh session thất bại) ---
    store.clearToken()

    // --- ASSERT: Token đã bị xóa và danh sách roles rỗng ---
    expect(store.token).toBe(null)
    expect(store.roles.length).toBe(0)
    expect(store.currentRole).toBe(null)
  })
})
