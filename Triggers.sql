
CREATE FUNCTION instrutores_internos (id_instrutor INTEGER) RETURNS refcursor AS $$
    DECLARE
        cursor_salarios refcursor;
        BEGIN
        OPEN cursor_salarios FOR SELECT instutor.salario
                                        FROM instutor
                                        WHERE id <> id_instrutor
                                        AND salario > 0;
        RETURN cursor_salarios;
    END;
    $$ LANGUAGE PLPGSQL;

DROP FUNCTION cria_instrutores CASCADE;
CREATE OR REPLACE FUNCTION cria_instrutores() RETURNS TRIGGER AS $$
    DECLARE
        media_salarial DECIMAL;
        instrutores_recebem_menos INTEGER DEFAULT 0;
        total_instrutores INTEGER DEFAULT 0;
        salario DECIMAL;
        percentual DECIMAL(5,2);
        cursor_salario refcursor;
    BEGIN
        SELECT AVG(instutor.salario) INTO media_salarial FROM instutor WHERE id <> NEW.id;

        IF NEW.salario > media_salarial THEN
            INSERT INTO log (info) VALUES (NEW.nome || ' recebe acima da média! ');

        END IF;

        SELECT instrutores_internos(NEW.id) INTO cursor_salario;
        LOOP
            FETCH cursor_salario INTO salario;
            EXIT WHEN NOT FOUND;
            total_instrutores := total_instrutores + 1;

            RAISE NOTICE 'Salário inserido: % Salário do instrutor existente: %', NEW.salario, salario;
            IF NEW.salario > salario THEN
                instrutores_recebem_menos := instrutores_recebem_menos + 1;
            END IF;
        END LOOP;

        percentual = instrutores_recebem_menos::DECIMAL / total_instrutores::DECIMAL * 100;
        ASSERT percentual < 100::DECIMAL, 'Noobs não pode receber mais do que todos os Veteranos!';

        INSERT INTO log (info, teste)
        VALUES (NEW.nome || ' recebe mais do que ' || percentual || '% da grade de instrutores', '');

        RETURN NEW;

        EXCEPTION
    WHEN undefined_column THEN
        RAISE NOTICE 'SOMETHING WITH WRONG';
        RAISE EXCEPTION '[ERROR] TRYHARD!';
        END;
    $$ LANGUAGE PLPGSQL;

DROP TRIGGER log_instrutores ON instutor;
CREATE TRIGGER log_instrutores BEFORE INSERT ON instutor
    FOR EACH ROW EXECUTE FUNCTION cria_instrutores();

SELECT * FROM instutor;
SELECT cria_instrutores('Trickster', 1030);
SELECT * FROM log;
INSERT INTO instutor (nome, salario) VALUES ('Trickster', 70000);

DO $$
    DECLARE
        cursor_salario refcursor;
        salario DECIMAL (8, 2);
        total_instrutores INTEGER DEFAULT 0;
        instrutores_recebem_menos INTEGER DEFAULT 0;
        percentual DECIMAL(5,2);
        BEGIN
        SELECT instrutores_internos(7) INTO cursor_salario;
        LOOP
            FETCH cursor_salario INTO salario;
            EXIT WHEN NOT FOUND;
            total_instrutores := total_instrutores + 1;

            IF 3000 > salario THEN
                instrutores_recebem_menos := instrutores_recebem_menos + 1;
            END IF;
        END LOOP;
        percentual = instrutores_recebem_menos::DECIMAL / total_instrutores::DECIMAL * 100;

        RAISE NOTICE 'Percentual: % %%', percentual;
    END;
$$;

