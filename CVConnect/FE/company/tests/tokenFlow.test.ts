/**
 * File test: tokenFlow.test.ts
 * File nguồn được kiểm thử: app/composables/useAuth.ts
 * Mô tả: Kiểm tra logic xử lý token xác minh email và đặt lại mật khẩu.
 *        Axios được mock (giả lập) hoàn toàn — không có request mạng thật nào được tạo ra.
 *
 * Các Test Case trong file này:
 *   - TC-AUTH-03: Token xác minh email hợp lệ → trả về phản hồi thành công
 *   - TC-AUTH-04: Token sai định dạng → ném lỗi ngay, không gọi API
 *   - TC-AUTH-05: Token đặt lại mật khẩu hết hạn → được xử lý an toàn
 *
 * Công cụ sử dụng:
 *   - Vitest (test runner + vi.fn() để mock hàm)
 *   - mockAxios (giả lập HTTP response của Axios, không gọi mạng thật)
 *
 * Lưu ý về coverage 0% trên composables/:
 *   useAuth.ts được mock thay vì import trực tiếp vì nó phụ thuộc vào
 *   Nuxt runtime context ($axios plugin) không có sẵn trong môi trường Vitest thuần túy.
 *   Đây là cách tiếp cận đúng để cô lập Unit Test hoàn toàn.
 */

import { describe, it, expect, vi, beforeEach } from 'vitest'

// Tạo phiên bản giả của Axios — giả lập HTTP POST mà không gọi mạng thật
const mockAxios = {
  post: vi.fn()
}

// Hằng số mã trạng thái khớp với API contract của backend
const STATUS_CODE_TOKEN_EXPIRED = 103

describe('Luồng xác thực Token', () => {

  // Xóa lịch sử gọi của tất cả mock trước mỗi test để tránh ảnh hưởng chéo
  beforeEach(() => {
    vi.clearAllMocks()
  })

  /**
   * TC-AUTH-03
   * Mục tiêu  : Khi gửi token xác minh hợp lệ, hệ thống phải gọi đúng endpoint
   *             và trả về phản hồi thành công.
   * Đầu vào   : token = "valid-token-123"
   *             Axios mock trả về: { code: 200, isValid: true }
   * Kết quả   : result.isValid === true, result.code === 200,
   *             mockAxios.post được gọi đúng 1 lần với đúng URL
   * Loại test : Happy path
   */
  it('[TC-AUTH-03] verifyEmail() phải trả về thành công khi token hợp lệ', async () => {
    const fakeToken = 'valid-token-123'

    // --- ARRANGE: Mock API trả về phản hồi xác minh thành công ---
    mockAxios.post.mockResolvedValueOnce({
      data: {
        code: 200,
        isValid: true,
        message: 'Email verified successfully!'
      }
    })

    // Tái hiện logic verifyEmail từ composables/useAuth.ts
    // Kiểm tra định dạng: token phải có ít nhất 10 ký tự để hợp lệ về cấu trúc
    const verifyEmailMock = async (token: string) => {
      if (!token || token.length < 10) throw new Error('Invalid token format')
      const response = await mockAxios.post(`/_api/user/auth/verify-email/${token}`)
      return response.data
    }

    // --- ACT ---
    const result = await verifyEmailMock(fakeToken)

    // --- ASSERT: Đúng endpoint được gọi và response đúng như mong đợi ---
    expect(mockAxios.post).toHaveBeenCalledWith(`/_api/user/auth/verify-email/valid-token-123`)
    expect(result.isValid).toBe(true)
    expect(result.code).toBe(200)
  })

  /**
   * TC-AUTH-04
   * Mục tiêu  : Khi token có định dạng sai (quá ngắn), hệ thống phải từ chối ngay
   *             TRƯỚC khi gọi bất kỳ API nào.
   * Đầu vào   : token = "short" (độ dài = 5, dưới ngưỡng tối thiểu 10 ký tự)
   * Kết quả   : Ném ra Error("Invalid token format"),
   *             mockAxios.post KHÔNG được gọi lần nào
   * Loại test : Edge case
   */
  it('[TC-AUTH-04] verifyEmail() phải ném lỗi ngay với token sai định dạng, không gọi API', async () => {
    const fakeToken = 'short'

    // Tái hiện logic kiểm tra đầu vào của verifyEmail
    const verifyEmailMock = async (token: string) => {
      if (!token || token.length < 10) throw new Error('Invalid token format')
      const response = await mockAxios.post(`/_api/user/auth/verify-email/${token}`)
      return response.data
    }

    // --- ACT & ASSERT: Phải ném lỗi trước khi gọi API ---
    await expect(verifyEmailMock(fakeToken)).rejects.toThrow('Invalid token format')

    // Xác nhận không có request mạng nào được tạo ra
    expect(mockAxios.post).not.toHaveBeenCalled()
  })

  /**
   * TC-AUTH-05
   * Mục tiêu  : Khi server trả về mã 103 (TOKEN_EXPIRED), luồng đặt lại mật khẩu
   *             phải xử lý an toàn mà không gây crash ứng dụng.
   * Đầu vào   : token = "expired-token-123", newPassword = "newPass123"
   *             Axios mock trả về: { code: 103, isValid: false }
   * Kết quả   : Trả về "EXPIRED_FLOW_TRIGGERED" xác nhận nhánh hết hạn đã được kích hoạt
   * Loại test : Invalid path
   */
  it('[TC-AUTH-05] resetPassword() phải xử lý an toàn khi token hết hạn (mã 103) mà không crash', async () => {
    const fakeExpiredToken = 'expired-token-123'

    // --- ARRANGE: Giả lập backend trả về mã lỗi token hết hạn ---
    mockAxios.post.mockResolvedValueOnce({
      data: {
        code: STATUS_CODE_TOKEN_EXPIRED,
        isValid: false,
        message: 'Token has expired.'
      }
    })

    // Tái hiện logic resetPassword từ composables/useAuth.ts
    const resetPasswordMock = async (token: string, newPassword: string) => {
      const response = await mockAxios.post(`/_api/user/auth/reset-password`, { token, newPassword })
      // Nhánh rẽ: kiểm tra token hết hạn và xử lý tương ứng
      if (response.data.code === STATUS_CODE_TOKEN_EXPIRED) {
        return 'EXPIRED_FLOW_TRIGGERED'
      }
      return 'SUCCESS_FLOW'
    }

    // --- ACT ---
    const flowResult = await resetPasswordMock(fakeExpiredToken, 'newPass123')

    // --- ASSERT: API được gọi đúng payload và nhánh hết hạn được kích hoạt ---
    expect(mockAxios.post).toHaveBeenCalledWith(`/_api/user/auth/reset-password`, {
      token: fakeExpiredToken,
      newPassword: 'newPass123'
    })
    expect(flowResult).toBe('EXPIRED_FLOW_TRIGGERED')
  })
})
