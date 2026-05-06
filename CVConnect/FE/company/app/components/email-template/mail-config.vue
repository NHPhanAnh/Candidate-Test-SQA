<template>
  <form class="mail-config" @submit.prevent="() => {}">
    <div class="row">
      <AppInputText
        :label="'Host'"
        :required="true"
        :error="formError.host"
        :placeholder="'Mời nhập host'"
        :value="formInput.host"
        @input="handleInput('host', $event)"
        @blur="validateKey('host')"
      />
      <AppInputText
        :label="'Port'"
        :required="true"
        :error="formError.port"
        :placeholder="'Mời nhập port'"
        :value="formInput.port"
        @input="handleInput('port', $event)"
        @blur="validateKey('port')"
      />
    </div>
    <div class="row">
      <AppInputText
        :label="'Email'"
        :required="true"
        :error="formError.email"
        :placeholder="'Mời nhập email'"
        :value="formInput.email"
        @input="handleInput('email', $event)"
        @blur="validateKey('email')"
      />
      <AppInputText
        :label="'Mật khẩu'"
        :required="true"
        :error="formError.password"
        :placeholder="'Mời nhập mật khẩu'"
        :value="formInput.password"
        :is-secured="true"
        @input="handleInput('password', $event)"
        @blur="validateKey('password')"
      />
    </div>
    <div class="row">
      <AppInputSearchSelect
        :label="'Giao thức'"
        :required="true"
        :options="protocolsList"
        :value="formInput.protocol"
        :error="formError.protocol"
        :placeholder="'Mời chọn giao thức'"
        :remote-filter="false"
        :multiple="false"
        :fetch-fn="null"
        :allow-clear="false"
        @open-update="handleProtocolOpenUpdate"
        @input="handleInput('protocol', $event)"
      />
      <UCheckbox
        class="checkbox"
        :model-value="formInput.isSsl"
        :label="'Mã hóa SSL'"
        @update:model-value="handleInput('isSsl', $event)"
      />
    </div>
    <div class="footer">
      <AppButton
        v-if="configDetail"
        :text="'Xóa'"
        class="button delete"
        @click="isDeleteModalOpen = true"
      />
      <AppButton
        :text="'Lưu'"
        :is-disabled="!isFormValid"
        class="button submit"
        @click="handleSubmit"
      />
    </div>
    <UModal
      :open="isDeleteModalOpen"
      title="Xóa cấu hình mail service"
      :ui="{ content: 'w-[840px] max-w-[840px]' }"
      @update:open="handleDeleteModalOpenUpdate"
    >
      <template #body>
        <ModalsDeleteConfirm :delete-list="['Cấu hình mail service']">
          <template #footer>
            <AppButton
              :text="'Đồng ý'"
              class="modal-delete-submit"
              :is-loading="isDeleting"
              @click="handleDelete"
            />
          </template>
        </ModalsDeleteConfirm>
      </template>
    </UModal>
  </form>
</template>
<script setup lang="ts">
import { cloneDeep, isEqual } from "lodash";
import { EMAIL_REGEX } from "~/const/auth";
import { BROADCAST_CHANNEL, BROADCAST_MESSAGE_TYPE, MAIL_PROTOCOLS } from "~/const/views/org-admin/email-template";

useHead({
  title: "Cấu hình mail service",
});

const {
  getMailTemplateConfig,
  createMailTemplateConfig,
  updateMailTemplateConfig,
  deleteMailTemplateConfig,
} = useMailTemplateApi();
const { setLoading } = useLoadingStore();

const emits = defineEmits<{
  (e: "onUpdate"): void;
}>();

const broadcastChannel = ref<BroadcastChannel | null>(null);
const isDeleteModalOpen = ref<boolean>(false);
const isDeleting = ref<boolean>(false);
const formInput = ref<Record<string, any>>({});

const formError = ref<Record<string, any>>({
  host: "",
  port: "",
  email: "",
  password: "",
  protocol: "",
});

const configDetail = ref<Record<string, any> | null>(null);
const formSnapshot = ref<Record<string, any> | null>(null);

onBeforeMount(async () => {
  broadcastChannel.value = new BroadcastChannel(BROADCAST_CHANNEL.MAIL_CONFIG);
  await fetchData();
});

const formRule: Record<string, any> = {
  host: [
    {
      error: "Mời nhập host",
      validator: (input: string | undefined) => !!input || !!input?.trim(),
    },
  ],
  port: [
    {
      error: "Mời nhập port",
      validator: (input: string | undefined) => !!input || !!input?.trim(),
    },
    {
      error: "Port không hợp lệ",
      validator: (input: string | undefined) => {
        const num = Number(input);
        return Number.isInteger(num) && num >= 1 && num <= 65535;
      },
    },
  ],
  email: [
    {
      error: "Mời nhập email",
      validator: (input: string | undefined) => !!input || !!input?.trim(),
    },
    {
      error: "Email không hợp lệ",
      validator: (input: string | undefined) => {
        return EMAIL_REGEX.test(input || "");
      },
    },
  ],
  password: [
    {
      error: "Mời nhập password",
      validator: (input: string | undefined) => !!input || !!input?.trim(),
    },
  ],
  protocol: [
    {
      error: "Mời chọn giao thức",
      validator: (input: Record<string, any>) => !!input,
    },
  ],
};

const protocolsList = computed(() => {
  return MAIL_PROTOCOLS;
});

function handleDeleteModalOpenUpdate(event: boolean) {
  if (!event) {
    isDeleteModalOpen.value = false;
  }
}

function handleProtocolOpenUpdate(value: boolean) {
  if (!value) {
    validateKey("protocol");
  }
}

async function fetchData() {
  setLoading(true);
  const res = await getMailTemplateConfig();
  configDetail.value = res.data;
  if (res.data) {
    formInput.value = {
      host: configDetail.value?.host,
      port: configDetail.value?.port,
      email: configDetail.value?.email,
      password: configDetail.value?.password,
      isSsl: configDetail.value?.isSsl,
      protocol: MAIL_PROTOCOLS.find(
        (protocol) => protocol.value === configDetail.value?.protocol,
      ),
    };
  } else {
    formInput.value = {
      host: "",
      port: "",
      email: "",
      password: "",
      isSsl: false,
      protocol: null,
    };
  }
  formSnapshot.value = cloneDeep(formInput.value);
  setLoading(false);
}

async function handleSubmit() {
  validateForm();
  if (!isFormValid.value) {
    return;
  }
  const payload = {
    ...formInput.value,
    protocol: formInput.value.protocol.value,
  };

  setLoading(true);
  if (configDetail.value) {
    await updateMailTemplateConfig(payload);
  } else {
    await createMailTemplateConfig(payload);
  }
  setLoading(false);
  await fetchData();
  broadcastChannel.value?.postMessage({
    type: BROADCAST_MESSAGE_TYPE.MAIL_CONFIG_UPDATE,
  });
}

async function handleDelete() {
  isDeleting.value = true;
  await deleteMailTemplateConfig();
  isDeleting.value = false;
  isDeleteModalOpen.value = false;
  fetchData();
  broadcastChannel.value?.postMessage({
    type: BROADCAST_MESSAGE_TYPE.MAIL_CONFIG_UPDATE,
  });
}

function handleInput(key: string, value: any) {
  formError.value[key] = "";
  formInput.value[key] = value;
}

function validateForm() {
  for (const key of Object.keys(
    formInput.value,
  ) as (keyof typeof formInput.value)[]) {
    validateKey(key);
  }
}

function validateKey(key: string) {
  const rules = formRule[key];
  if (!rules) {
    return;
  }
  for (const rule of rules) {
    const isValid = rule.validator(formInput.value[key]);
    if (!isValid) {
      formError.value[key] = rule.error;
      break;
    }
  }
}

const isFormValid = computed(() => {
  for (const key of Object.keys(
    formError.value,
  ) as (keyof typeof formError.value)[]) {
    if (formError.value[key]) {
      return false;
    }
  }
  if (isEqual(formInput.value, formSnapshot.value)) {
    return false;
  }
  return true;
});

onBeforeUnmount(() => {
  broadcastChannel.value?.close();
});
</script>
<style lang="scss" scoped>
.mail-config {
  display: flex;
  flex-direction: column;
  gap: 8px;

  .row {
    display: flex;
    flex-direction: row;
    gap: 8px;
    @include respond-max($breakpoint-lg) {
      flex-wrap: wrap;

      .checkbox {
        margin-left: 0px;
      }

      :deep(.search-select-input),
      :deep(.text-input),
      :deep(.number-input),
      :deep(.datepicker-input) {
        max-width: calc((100% - 8px) * 1);
        min-width: calc((100% - 8px) * 1);
      }
    }
  }

  .checkbox {
    align-items: center;
    margin-left: 24px;
    :deep(label) {
      margin-top: 4px;
      color: $text-light;
      font-weight: 400;
      cursor: pointer !important;
    }
    :deep(button) {
      margin-top: 4px;
      cursor: pointer !important;
    }
  }

  .title {
    color: $color-primary-400;
    font-size: 16px;
    line-height: 20px;
    font-weight: 600;
  }

  .loading {
    height: 160px;
    display: flex;
    align-items: center;
    justify-content: center;

    .iconify {
      display: block;
    }
  }

  :deep(.number-input),
  :deep(.text-input) {
    .input-wrapper {
      .input {
        padding: 6px 8px;
        input {
          font-size: 14px;
        }
      }
    }
  }

  :deep(.search-select-input),
  :deep(.text-input),
  :deep(.number-input),
  :deep(.datepicker-input) {
    max-width: calc((100% - 24px) * 0.5);
    min-width: calc((100% - 24px) * 0.5);
  }

  .footer {
    display: flex;
    flex-direction: row;
    justify-content: flex-end;
    gap: 8px;
    margin-top: 12px;

    .button {
      padding: 4px 8px;
      border: 1px solid $color-primary-400;
      border-radius: 4px;
      min-width: 102px;

      &.delete {
        background-color: white;
        color: $color-primary-400;
      }

      &.submit {
        background-color: $color-primary-400;
        color: $text-dark;

        &.disabled {
          border-color: $color-gray-300;
          background-color: $color-gray-300;
          color: $text-dark;
        }
      }
    }
  }
}
</style>
