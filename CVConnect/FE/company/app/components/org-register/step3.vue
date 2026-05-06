<template>
  <div class="step3">
    <div class="form-body">
      <div class="form-body__column">
        <div class="column">
          <AppInputText
            :value="props.data.fullName"
            :label="'Tên đầy đủ'"
            :required="true"
            :error="formError.fullName"
            @input="handleInput('fullName', $event)"
            @blur="validateKey('fullName')"
          />
          <AppInputText
            :value="props.data.username"
            :label="'Tên đăng nhập'"
            :required="true"
            :error="formError.username"
            @input="handleInput('username', $event)"
            @blur="validateKey('username')"
          />
        </div>
        <div class="column">
          <AppInputText
            :value="props.data.email"
            :label="'Email'"
            :required="true"
            :error="formError.email"
            :tooltip="'Email này được dùng để xác thực tài khoản của bạn'"
            @input="handleInput('email', $event)"
            @blur="validateKey('email')"
          />
          <AppInputText
            :value="props.data.password"
            :label="'Mật khẩu'"
            :required="true"
            :error="formError.password"
            :is-secured="true"
            :show-error="false"
            @input="handleInput('password', $event)"
            @blur="validateKey('password')"
          />
          <AppInputText
            :value="props.data.passwordConfirm"
            :label="'Xác nhận mật khẩu'"
            :required="true"
            :error="formError.passwordConfirm"
            :is-secured="true"
            @input="handleInput('passwordConfirm', $event)"
            @blur="validateKey('passwordConfirm')"
          />
          <div class="password-checklist">
            <div
              v-for="check of passwordChecklist"
              :key="check.key"
              class="checklist__item"
              :class="{ done: check.isDone }"
            >
              <Icon
                :name="check.isDone ? 'mdi:check' : 'mdi:close'"
                class="icon"
              />
              <div class="text">{{ check.text }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import { EMAIL_REGEX, PASSWORD_REGEX } from "~/const/auth";

type TProps = {
  data: Record<string, any>;
};

const props = defineProps<TProps>();
const emits = defineEmits<{
  (e: "input", event: Record<string, any>): void;
}>();

const formError = ref({
  fullName: "",
  email: "",
  username: "",
  password: "",
  passwordConfirm: "",
});

const passwordChecklist = ref([
  {
    key: "lowercase",
    text: "Ít nhất 1 chữ thường",
    regex: /\p{Ll}/u,
    isDone: false,
  },
  {
    key: "uppercase",
    text: "Ít nhất 1 chữ hoa",
    regex: /\p{Lu}/u,
    isDone: false,
  },
  {
    key: "digit",
    text: "Ít nhất 1 chữ số",
    regex: /\d/,
    isDone: false,
  },
  {
    key: "length",
    text: "Độ dài từ 8 đến 20 ký tự",
    regex: /^.{8,20}$/,
    isDone: false,
  },
  {
    key: "nospace",
    text: "Không chứa khoảng trắng",
    regex: /^\S*$/,
    isDone: false,
  },
]);

const formRules = {
  fullName: [
    (input: string) => {
      if (!input.trim()) {
        formError.value.fullName = "Mời nhập tên đầy đủ";
        return false;
      }
      return true;
    },
  ],
  email: [
    (input: string) => {
      if (!input.trim()) {
        formError.value.email = "Mời nhập email";
        return false;
      }
      return true;
    },
    (input: string) => {
      const isValid = EMAIL_REGEX.test(input);
      if (!isValid) {
        formError.value.email = "Email không hợp lệ";
        return false;
      }
      return true;
    },
  ],
  username: [
    (input: string) => {
      if (!input.trim()) {
        formError.value.username = "Mời nhập tên đăng nhập";
        return false;
      }
      return true;
    },
  ],
  password: [
    (input: string) => {
      if (!input.trim()) {
        formError.value.password = "Mời nhập mật khẩu";
        return false;
      }
      return true;
    },
    (input: string) => {
      const isValid = PASSWORD_REGEX.test(input);
      if (!isValid) {
        formError.value.password =
          "Mật khẩu phải từ 8 đến 20 kí tự, ít nhất 1 kí tự hoa, thường, số và không chứa khoảng trắng";
        return false;
      }
      return true;
    },
  ],
  passwordConfirm: [
    (input: string) => {
      if (!input.trim()) {
        formError.value.passwordConfirm = "Mời xác nhận mật khẩu";
        return false;
      }
      return true;
    },
    (input: string) => {
      if (
        props.data.password.trim() &&
        props.data.password.trim() !== input.trim()
      ) {
        formError.value.passwordConfirm = "Mật khẩu không trùng khớp";
        return false;
      }
      return true;
    },
  ],
};

const validateKey = (key: keyof typeof props.data) => {
  const input = props.data[key];
  const rules = formRules[key as keyof typeof formRules];
  for (const rule of rules) {
    const ok = rule(input);
    if (!ok) {
      break;
    }
  }
};

const handleInput = (key: string, value: string) => {
  // Emitting
  emits("input", { key, value });
  formError.value[key as keyof typeof formError.value] = "";
};

watch(props.data, (val) => {
  passwordChecklist.value = passwordChecklist.value.map((rule) => {
    if (!val.password) {
      return {
        ...rule,
        isDone: false,
      };
    }
    return {
      ...rule,
      isDone: rule.regex.test(val.password),
    };
  });
});
</script>
<style lang="scss" scoped>
.step3 {
  display: flex;
  flex-direction: column;
  width: 100%;

  .form-body {
    margin-top: 12px;
    display: flex;
    flex-direction: column;
    gap: 8px;

    .password-checklist {
      display: flex;
      flex-direction: column;
      gap: 4px;
      font-size: 12px;
      line-height: 14px;
      padding-left: 8px;

      .checklist__item {
        display: flex;
        flex-direction: row;
        align-items: center;
        gap: 4px;
        color: $color-danger;

        &.done {
          color: $color-success;

          span.icon {
            display: inline-block;
            color: $color-success;
          }
        }

        span.icon {
          display: inline-block;
          color: $color-danger;
        }
      }
    }

    &__column {
      display: flex;
      flex-direction: row;
      gap: 8px;
      .column {
        display: flex;
        flex-direction: column;
        gap: 4px;
        flex: 1;
      }
    }

    .register-button {
      margin-top: 12px;
      background-color: $color-primary-500;
      border-radius: 8px;
      color: $text-dark;

      &.disabled {
        background-color: $color-gray-400;
      }
    }

    .label,
    span {
      font-size: 14px;
      line-height: 21px;
      color: $text-light;
    }

    .label {
      margin-bottom: 4px;
    }
  }
}
</style>
