<template>
  <footer class="bg-[#2E2E2E] text-[#FCF6F5] py-10">
    <div class="max-w-7xl mx-auto px-6 grid grid-cols-1 md:grid-cols-3 gap-8">
      <!-- Logo + Giới thiệu -->
      <div>
        <!-- 👉 Chèn logo vào đây -->
        <div class="mb-4">
          <img
            src="/logo-horizontal-white.svg"
            alt="CVConnect Logo"
            class="h-14"
          />
        </div>
        <p class="text-sm leading-relaxed text-gray-300">
          CVConnect – Nền tảng quản lí ứng viên & tuyển dụng thông minh. Giúp
          doanh nghiệp kết nối nhân tài dễ dàng và hiệu quả.
        </p>
      </div>

      <!-- Liên kết nhanh -->
      <div>
        <h4 class="font-semibold text-[#f9e6e8] mb-4">Liên kết</h4>
        <ul class="space-y-2 text-sm">
          <li>
            <NuxtLink to="/" class="hover:text-[#c90a1f]">Trang chủ</NuxtLink>
          </li>
          <li>
            <NuxtLink to="/about" class="hover:text-[#c90a1f]"
              >Về chúng tôi</NuxtLink
            >
          </li>
          <li>
            <NuxtLink to="/jobs" class="hover:text-[#c90a1f]"
              >Tin tuyển dụng</NuxtLink
            >
          </li>
          <li>
            <NuxtLink to="/contact" class="hover:text-[#c90a1f]"
              >Liên hệ</NuxtLink
            >
          </li>
        </ul>
      </div>

      <!-- Hỗ trợ -->
      <!-- <div> -->
      <!--   <h4 class="font-semibold text-[#f9e6e8] mb-4">Hỗ trợ</h4> -->
      <!--   <ul class="space-y-2 text-sm"> -->
      <!--     <li> -->
      <!--       <NuxtLink to="/help" class="hover:text-[#c90a1f]" -->
      <!--         >Trung tâm trợ giúp</NuxtLink -->
      <!--       > -->
      <!--     </li> -->
      <!--     <li> -->
      <!--       <NuxtLink to="/privacy" class="hover:text-[#c90a1f]" -->
      <!--         >Chính sách bảo mật</NuxtLink -->
      <!--       > -->
      <!--     </li> -->
      <!--     <li> -->
      <!--       <NuxtLink to="/terms" class="hover:text-[#c90a1f]" -->
      <!--         >Điều khoản sử dụng</NuxtLink -->
      <!--       > -->
      <!--     </li> -->
      <!--     <li> -->
      <!--       <NuxtLink to="/faq" class="hover:text-[#c90a1f]">FAQs</NuxtLink> -->
      <!--     </li> -->
      <!--   </ul> -->
      <!-- </div> -->

      <!-- Liên hệ -->
      <div>
        <h4 class="font-semibold text-[#f9e6e8] mb-4">Liên hệ</h4>
        <p class="text-sm">123 Nguyễn Văn A, Hà Nội</p>
        <p class="text-sm">0123 456 789</p>
        <p class="text-sm">support@cvconnect.com</p>
      </div>
    </div>

    <!-- Copyright -->
    <div
      class="mt-10 border-t border-gray-700 pt-4 text-center text-sm text-gray-400"
    >
      © {{ new Date().getFullYear() }} CVConnect. All rights reserved.
    </div>
  </footer>
</template>

<script setup lang="ts">
// Không cần script phức tạp, chỉ render tĩnh
</script>
