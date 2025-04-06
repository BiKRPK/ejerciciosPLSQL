CREATE TABLE PROVINCIAS (
    --He utilizado de referencia para el tamaño de la id los codigos que da el INE
    --https://www.ine.es/daco/daco42/codmun/codmun02/02codmun.xls
    id_provincia VARCHAR(2) PRIMARY KEY, 
    descripcion VARCHAR(50) NOT NULL,
    f_baja DATE DEFAULT NULL
);

CREATE TABLE MUNICIPIOS (
    id_municipio VARCHAR(4) PRIMARY KEY,
    descripcion VARCHAR(50) NOT NULL,
    num_habitantes NUMBER,
    f_baja DATE DEFAULT NULL,
    
    id_provincia VARCHAR2(2) NOT NULL,
    CONSTRAINT fk_municipio_provincia FOREIGN KEY (id_provincia) REFERENCES PROVINCIAS(id_provincia)
);

CREATE TABLE USUARIOS (
    dni VARCHAR(9) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    direccion VARCHAR(200) NOT NULL,
    num_habitantes NUMBER,
    f_baja DATE DEFAULT NULL,
    
    id_municipio VARCHAR2(4) NOT NULL,
    CONSTRAINT fk_usuario_municipio FOREIGN KEY (id_municipio) REFERENCES MUNICIPIOS(id_municipio)
);

--CURSOR EXPLICITO
DECLARE
    v_ciudad municipios.descripcion%type := &n_ciudad; --'Valencia'

    CURSOR c_usuarios_vlc IS
        SELECT u.dni, u.nombre, u.apellidos
        FROM USUARIOS u
        JOIN MUNICIPIOS m using(id_municipio)
        WHERE m.descripcion = v_ciudad
            AND u.f_baja IS NULL;
            
    v_dni usuarios.dni%type;
    v_nombre usuarios.nombre%type;
    v_apellidos usuarios.apellidos%type;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('Usuarios de ' || v_ciudad || ':');
    OPEN c_usuarios_vlc;
        LOOP
            FETCH c_usuarios_vlc into v_dni, v_nombre, v_apellidos;
            EXIT WHEN c_usuarios_vlc%notfound;
            DBMS_OUTPUT.PUT_LINE('DNI: ' || v_dni || ', Nombre: ' || v_nombre || ', Apellidos: ' || v_apellidos);
        END LOOP;
    CLOSE c_usuarios_vlc;
    
END;


-- NO ENTIENDO A QUE OS REFERIS CON CURSOR IMPLICITO
-- ESTO VA A DEVOLVER TOO_MANY_ROWS Y NO SERVIRIA

-- CURSOR IMPLICITO
DECLARE
    v_ciudad municipios.descripcion%type := &n_ciudad; --'Valencia'
BEGIN
    DBMS_OUTPUT.PUT_LINE('Usuarios de ' || v_ciudad || ':');
    SELECT u.dni, u.nombre, u.apellidos
    INTO v_dni, v_nombre, v_apellidos
    FROM USUARIOS u
    JOIN MUNICIPIOS m using(id_municipio)
    WHERE m.descripcion = v_ciudad
        AND u.f_baja IS NULL;
            
    DBMS_OUTPUT.PUT_LINE('DNI: ' || usuario.dni || ', Nombre: ' || usuario.nombre || ', Apellidos: ' || usuario.apellidos);
    END LOOP;

END;


CREATE OR REPLACE PACKAGE PCK_EJERCICIO_PRUEBA AS
  FUNCTION f_Municipios_Validos (p_cod_municipio IN MUNICIPIOS.id_municipio%type) RETURN BOOLEAN;
END PCK_EJERCICIO_PRUEBA;
/

CREATE OR REPLACE PACKAGE BODY PCK_EJERCICIO_PRUEBA AS
    FUNCTION f_Municipios_Validos (p_cod_municipio IN MUNICIPIOS.id_municipio%type)
        RETURN BOOLEAN
    AS
        v_municipio municipios%rowtype;
        
    BEGIN
        SELECT *
        INTO v_municipio
        FROM MUNICIPIOS
        WHERE id_municipio = p_cod_municipio;
        
        IF v_municipio.num_habitantes >= 1000 THEN
            RETURN TRUE;
        ELSIF v_municipio.f_baja IS NOT NULL THEN
            RETURN FALSE;
        ELSIF v_municipio.id_provincia = '12' AND v_municipio.num_habitantes >= 400 THEN
            RETURN TRUE;
        ELSIF v_municipio.id_provincia = '46' AND v_municipio.num_habitantes >= 650 THEN
            RETURN TRUE;
        ELSIF v_municipio.id_provincia = '03' AND v_municipio.num_habitantes > 500 THEN
            RETURN TRUE;
        END IF;
        
        RETURN FALSE;
     
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('NO EXISTE EL MUNICIPIO ' || p_cod_municipio);
                RETURN FALSE;
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('ERROR NO TRATADO');
                RETURN FALSE;
    END f_Municipios_Validos;
END PCK_EJERCICIO_PRUEBA;
/