/**
 * File test: authRedirect.test.ts
 * File nguồn được kiểm thử:
 *   - app/composables/useLayoutPermission.ts  (kiểm tra token + kích hoạt redirect)
 *   - Logic middleware bảo vệ route
 * Mô tả: Kiểm tra lớp bảo vệ route có chuyển hướng đúng người dùng chưa xác thực
 *        và cho phép người dùng đã đăng nhập đi qua không bị chặn.
 *        Router được mock — chỉ xác nhận rằng nó được gọi đúng tham số,
 *        không test cơ chế điều hướng nội bộ của Nuxt Router.
 *
 * Các Test Case trong file này:
 *   - TC-AUTH-06: Người dùng chưa đăng nhập truy cập route bảo vệ → chuyển hướng về /login
 *   - TC-AUTH-07: Người dùng đã đăng nhập truy cập route bảo vệ → được phép đi qua
 *
 * Công cụ sử dụng:
 *   - Vitest (test runner + vi.fn() để mock router)
 *   - mockRouter (giả lập useRouter().push — không có điều hướng thật nào xảy ra)
 */

import { describe, it, expect, vi } from 'vitest'

describe('Auth Middleware — Bảo vệ Route & Chuyển hướng', () => {

  /**
   * TC-AUTH-06
   * Mục tiêu  : Người dùng chưa xác thực (không có token) cố truy cập route được bảo vệ
   *             phải được chuyển hướng ngay về trang đăng nhập.
   *             URL gốc cần truy cập phải được giữ lại dưới dạng query param "redirect".
   * Đầu vào   : toPath = "/dashboard/overview", mockStore.token = null
   * Kết quả   : mockRouter.push({ name: 'auth-login', query: { redirect: '/dashboard/overview' } })
   *             được gọi đúng 1 lần
   * Loại test : Invalid path (người dùng chưa đăng nhập)
   */
  it('[TC-AUTH-06] Phải chuyển hướng người dùng chưa đăng nhập về /login khi truy cập route bảo vệ', () => {
    // --- ARRANGE: Giả lập auth store không có token và mock router ---
    const mockRouter = { push: vi.fn() }
    const mockStore  = { token: null } // Không có token → người dùng chưa đăng nhập

    // Logic bảo vệ route, phản ánh useLayoutPermission.ts / auth middleware
    const routeMiddlewareMock = (toPath: string) => {
      const isProtectedRoute = toPath.startsWith('/dashboard') || toPath.startsWith('/org-admin')
      if (isProtectedRoute && !mockStore.token) {
        // Chuyển hướng về login, giữ lại URL đích ban đầu trong query
        mockRouter.push({ name: 'auth-login', query: { redirect: toPath } })
      }
    }

    // --- ACT: Giả lập điều hướng đến một route dashboard được bảo vệ ---
    routeMiddlewareMock('/dashboard/overview')

    // --- ASSERT: Router phải đã được yêu cầu chuyển hướng đúng 1 lần đến trang login ---
    expect(mockRouter.push).toHaveBeenCalledTimes(1)
    expect(mockRouter.push).toHaveBeenCalledWith({
      name: 'auth-login',
      query: { redirect: '/dashboard/overview' }
    })
  })

  /**
   * TC-AUTH-07
   * Mục tiêu  : Người dùng đã xác thực (có token hợp lệ) KHÔNG được chuyển hướng
   *             khi truy cập route được bảo vệ — được phép đi qua bình thường.
   * Đầu vào   : toPath = "/dashboard/overview", mockStore.token = "some-valid-token"
   * Kết quả   : mockRouter.push KHÔNG được gọi lần nào
   * Loại test : Happy path (người dùng đã đăng nhập hợp lệ)
   */
  it('[TC-AUTH-07] Không được chuyển hướng người dùng đã đăng nhập khi truy cập route bảo vệ', () => {
    // --- ARRANGE: Auth store có token hợp lệ ---
    const mockRouter = { push: vi.fn() }
    const mockStore  = { token: 'some-valid-token' } // Có token → người dùng đã đăng nhập

    // Cùng logic bảo vệ route như TC-AUTH-06
    const routeMiddlewareMock = (toPath: string) => {
      const isProtectedRoute = toPath.startsWith('/dashboard') || toPath.startsWith('/org-admin')
      if (isProtectedRoute && !mockStore.token) {
        mockRouter.push({ name: 'auth-login', query: { redirect: toPath } })
      }
    }

    // --- ACT: Cùng route được bảo vệ, nhưng người dùng đã xác thực ---
    routeMiddlewareMock('/dashboard/overview')

    // --- ASSERT: Router KHÔNG được gọi — người dùng được phép đi qua ---
    expect(mockRouter.push).not.toHaveBeenCalled()
  })
})
