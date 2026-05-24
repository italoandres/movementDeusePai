-- ============================================
-- TRIGGER BLINDADO: Criar perfil automaticamente após signup
-- Nunca bloqueia o signup — usa EXCEPTION handler
-- ============================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  BEGIN
    INSERT INTO public.profiles (id)
    VALUES (NEW.id);
  EXCEPTION WHEN OTHERS THEN
    -- Se falhar por qualquer motivo, apenas loga e continua
    -- O ProfileService no Flutter vai garantir o profile depois
    RAISE WARNING 'handle_new_user failed for %: %', NEW.id, SQLERRM;
  END;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger que executa após inserção na tabela auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- COMENTÁRIO
-- ============================================
COMMENT ON FUNCTION public.handle_new_user() IS 'Cria profile mínimo (apenas id) quando user é criado. Blindado com EXCEPTION para nunca bloquear signup. ProfileService preenche o restante.';
