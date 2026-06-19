# Phase 4 — AI Assistant Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development

**Goal:** Chat-based AI assistant answering business questions using local data

**Architecture:** Rule-based intent parser + Hive queries + chat UI

**Tech Stack:** Flutter, flutter_bloc, hive, intl

---

### Task 1: Create IntentParser

**Files:**
- Create: `lib/features/ai_assistant/data/services/intent_parser.dart`
- Create: `test/features/ai_assistant/data/services/intent_parser_test.dart`

### Task 2: Create BusinessAssistant

**Files:**
- Create: `lib/features/ai_assistant/domain/services/business_assistant.dart`
- Create: `lib/features/ai_assistant/data/services/business_assistant_impl.dart`
- Create: `test/features/ai_assistant/data/services/business_assistant_impl_test.dart`

### Task 3: Create AssistantBloc

**Files:**
- Create: `lib/features/ai_assistant/presentation/bloc/assistant_event.dart`
- Create: `lib/features/ai_assistant/presentation/bloc/assistant_state.dart`
- Create: `lib/features/ai_assistant/presentation/bloc/assistant_bloc.dart`
- Create: `test/features/ai_assistant/presentation/bloc/assistant_bloc_test.dart`

### Task 4: Create Chat UI + routes

**Files:**
- Create: `lib/features/ai_assistant/presentation/pages/assistant_page.dart`
- Modify: `lib/config/routes/app_routes.dart`
- Modify: `lib/core/service_locator.dart`
- Modify: `lib/main.dart`
