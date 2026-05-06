<template>
  <div class="right">
    <div class="content">
      <div class="row">
        <div class="block">
          <div class="label">
            <Icon name="material-symbols:person-edit-outline-rounded" />
            <span>Hội đồng</span>
          </div>
          <div class="list">
            <div
              v-for="user of detail.participants"
              :key="user.id"
              class="user-block"
            >
              <div class="name">{{ user.fullName }}</div>
              <div class="email">{{ user.email }}</div>
            </div>
          </div>
        </div>
      </div>
      <div class="row">
        <div class="block">
          <div class="label">
            <Icon name="material-symbols:person-pin-circle-outline-rounded" />
            <span>Ứng viên</span>
          </div>
          <div class="list">
            <div
              v-for="user of detail.candidates"
              :key="user.id"
              class="user-block"
            >
              <div class="name">
                {{ user.fullName
                }}<span class="cursor-pointer" @click="handleToDetail(user)">{{
                  "Xem chi tiết"
                }}</span>
              </div>
              <div class="email">{{ user.email }}</div>
              <div class="phone">{{ user.phone }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
type TProps = {
  detail: any;
};

const props = defineProps<TProps>();
const router = useRouter();

function handleToDetail(user: any) {
  console.log(user);
  const url = router.resolve(`/org/candidate/detail/${user.id}`).href;
  window.open(url, "_blank");
}
</script>
<style lang="scss" scoped>
.right {
  max-height: 100%;
  display: flex;
  flex-direction: column;
  width: 60%;
  gap: 8px;

  .header {
    font-size: 16px;
    font-weight: 500;
  }

  .list {
    display: flex;
    flex-direction: column;
    gap: 4px;
  }

  .user-block {
    display: flex;
    flex-direction: column;
    gap: 2px;
    border: 1px solid $color-gray-200;
    border-radius: 4px;
    padding: 4px 6px;
    min-width: 240px;
    width: 100%;

    .name {
      display: flex;
      flex-direction: row;
      justify-content: space-between;
    }

    .email,
    .phone {
      font-weight: 400;
      color: $color-gray-400;
    }
    .phone {
      font-style: italic;
    }
  }

  .content {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 8px;
    overflow: auto;
    min-height: 0;

    .row {
      display: flex;
      flex-direction: row;
      justify-content: space-between;
      gap: 8px;
      flex-wrap: wrap;
    }

    .block {
      font-size: 14px;
      display: flex;
      flex-direction: column;
      gap: 4px;
      width: 100%;

      .iconify {
        display: block;
        font-size: 14px;
        width: 14px;
        height: 14px;
      }

      .label {
        font-weight: 600;
        display: flex;
        flex-direction: row;
        align-items: center;
        gap: 6px;
      }
    }
  }
}
</style>
