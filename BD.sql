use master
go
-- Comprobar si la base de datos existe
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'DB_ATIANAS')
BEGIN
    -- Si existe, eliminar la base de datos
    DROP DATABASE DB_ATIANAS
END
GO

-- Crear la base de datos
CREATE DATABASE DB_ATIANAS
GO

-- Usar la base de datos recién creada
USE DB_ATIANAS
GO


CREATE TABLE CATEGORIA(
IdCategoria int primary key identity,
Descripcion varchar(100),
Activo bit default 1,
FechaRegistro datetime default getdate()
)

go

CREATE TABLE MARCA(
IdMarca int primary key identity,
Descripcion varchar(100),
Activo bit default 1,
FechaRegistro datetime default getdate()
)

go

CREATE TABLE PRODUCTO(
IdProducto int primary key identity,
Nombre varchar(500),
Descripcion varchar(500),
IdMarca int references Marca(IdMarca),
IdCategoria int references Categoria(IdCategoria),
Precio decimal(10,2) default 0,
Stock int,
RutaImagen varchar(100),
Activo bit default 1,
FechaRegistro datetime default getdate()
)

go

CREATE TABLE USUARIO(
IdUsuario int primary key identity,
Nombres varchar(100),
Apellidos varchar(100),
Correo varchar(100),
Contrasena varchar(100),
EsAdministrador bit,
Activo bit default 1,
FechaRegistro datetime default getdate()
)

go


CREATE TABLE CARRITO(
IdCarrito int primary key identity,
IdUsuario int references USUARIO(IdUsuario),
IdProducto int references PRODUCTO(IdProducto)
)

go



create table COMPRA(
IdCompra int primary key identity,
IdUsuario int references USUARIO(IdUsuario),
TotalProducto int,
Total decimal(10,2),
Contacto varchar(50),
Telefono varchar(50),
Direccion varchar(500),
IdDistrito varchar(10),
FechaCompra datetime default getdate()
)

go

create table DETALLE_COMPRA(
IdDetalleCompra int primary key identity,
IdCompra int references Compra(IdCompra),
IdProducto int references PRODUCTO(IdProducto),
Cantidad int,
Total decimal(10,2)
)

go

CREATE TABLE DEPARTAMENTO (
  IdDepartamento varchar(2) NOT NULL,
  Descripcion varchar(45) NOT NULL
) 

go

CREATE TABLE PROVINCIA (
  IdProvincia varchar(4) NOT NULL,
  Descripcion varchar(45) NOT NULL,
  IdDepartamento varchar(2) NOT NULL
) 

go

CREATE TABLE DISTRITO (
  IdDistrito varchar(6) NOT NULL,
  Descripcion varchar(45) NOT NULL,
  IdProvincia varchar(4) NOT NULL,
  IdDepartamento varchar(2) NOT NULL
)

-- Procedimientos Almacenados
GO
create proc sp_obtenerCategoria
as
begin
 select * from CATEGORIA
end


go


--PROCEDIMIENTO PARA GUARDAR CATEGORIA
CREATE PROC sp_RegistrarCategoria(
@Descripcion varchar(50),
@Resultado bit output
)as
begin
	SET @Resultado = 1
	IF NOT EXISTS (SELECT * FROM CATEGORIA WHERE Descripcion = @Descripcion)

		insert into CATEGORIA(Descripcion) values (
		@Descripcion
		)
	ELSE
		SET @Resultado = 0
	
end

go

--PROCEDIMIENTO PARA MODIFICAR CATEGORIA
create procedure sp_ModificarCategoria(
@IdCategoria int,
@Descripcion varchar(60),
@Activo bit,
@Resultado bit output
)
as
begin
	SET @Resultado = 1
	IF NOT EXISTS (SELECT * FROM CATEGORIA WHERE Descripcion =@Descripcion and IdCategoria != @IdCategoria)
		
		update CATEGORIA set 
		Descripcion = @Descripcion,
		Activo = @Activo
		where IdCategoria = @IdCategoria
	ELSE
		SET @Resultado = 0

end


GO
create proc sp_obtenerMarca
as
begin
 select * from MARCA
end

go

--PROCEDIMIENTO PARA GUARDAR MARCA
CREATE PROC sp_RegistrarMarca(
@Descripcion varchar(50),
@Resultado bit output
)as
begin
	SET @Resultado = 1
	IF NOT EXISTS (SELECT * FROM MARCA WHERE Descripcion = @Descripcion)

		insert into MARCA(Descripcion) values (
		@Descripcion
		)
	ELSE
		SET @Resultado = 0
	
end

go

--PROCEDIMIENTO PARA MODIFICAR MARCA
create procedure sp_ModificarMarca(
@IdMarca int,
@Descripcion varchar(60),
@Activo bit,
@Resultado bit output
)
as
begin
	SET @Resultado = 1
	IF NOT EXISTS (SELECT * FROM MARCA WHERE Descripcion =@Descripcion and IdMarca != @IdMarca)
		
		update MARCA set 
		Descripcion = @Descripcion,
		Activo = @Activo
		where IdMarca = @IdMarca
	ELSE
		SET @Resultado = 0

end

GO
create proc sp_obtenerProducto
as
begin
 select p.*,m.Descripcion[DescripcionMarca],c.Descripcion[DescripcionCategoria] from PRODUCTO p
 inner join marca m on m.IdMarca = p.IdMarca
 inner join CATEGORIA c on c.IdCategoria = p.IdCategoria

end

go

create proc sp_registrarProducto(
@Nombre varchar(500),
@Descripcion varchar(500),
@IdMarca int,
@IdCategoria int,
@Precio decimal(10,2),
@Stock int,
@RutaImagen varchar(500),
@Resultado int output
)
as
begin
	SET @Resultado = 0
	IF NOT EXISTS (SELECT * FROM PRODUCTO WHERE Descripcion = @Descripcion)
	begin
		insert into PRODUCTO(Nombre,Descripcion,IdMarca,IdCategoria,Precio,Stock,RutaImagen) values (
		@Nombre,@Descripcion,@IdMarca,@IdCategoria,@Precio,@Stock,@RutaImagen)

		SET @Resultado = scope_identity()
	end
end

go

create proc sp_editarProducto(
@IdProducto int,
@Nombre varchar(500),
@Descripcion varchar(500),
@IdMarca int,
@IdCategoria int,
@Precio decimal(10,2),
@Stock int,
@Activo bit,
@Resultado bit output
)
as
begin
	SET @Resultado = 0
	IF NOT EXISTS (SELECT * FROM PRODUCTO WHERE Descripcion = @Descripcion and IdProducto != @IdProducto)
	begin
		update PRODUCTO set 
		Nombre = @Nombre,
		Descripcion = @Descripcion,
		IdMarca = @IdMarca,
		IdCategoria = @IdCategoria,
		Precio =@Precio ,
		Stock =@Stock ,
		Activo = @Activo where IdProducto = @IdProducto

		SET @Resultado =1
	end
end

go
create proc sp_actualizarRutaImagen(
@IdProducto int,
@RutaImagen varchar(500)
)
as
begin
	update PRODUCTO set RutaImagen = @RutaImagen where IdProducto = @IdProducto
end

go

create proc sp_obtenerUsuario(
@Correo varchar(100),
@Contrasena varchar(100)
)
as
begin
	IF EXISTS (SELECT * FROM usuario WHERE correo = @Correo and contrasena = @Contrasena)
	begin
		SELECT IdUsuario,Nombres,Apellidos,Correo,Contrasena,EsAdministrador FROM usuario WHERE correo = @Correo and contrasena = @Contrasena
	end
end


go

create proc sp_registrarUsuario(
@Nombres varchar(100),
@Apellidos varchar(100),
@Correo varchar(100),
@Contrasena varchar(100),
@EsAdministrador bit,
@Resultado int output
)
as
begin
	SET @Resultado = 0
	IF NOT EXISTS (SELECT * FROM USUARIO WHERE Correo = @Correo)
	begin
		insert into USUARIO(Nombres,Apellidos,Correo,Contrasena,EsAdministrador) values
		(@Nombres,@Apellidos,@Correo,@Contrasena,@EsAdministrador)

		SET @Resultado = scope_identity()
	end
end
go

create proc sp_InsertarCarrito(
@IdUsuario int,
@IdProducto int,
@Resultado int output
)
as
begin
	set @Resultado = 0
	if not exists (select * from CARRITO where IdProducto = @IdProducto and IdUsuario = @IdUsuario)
	begin
		update PRODUCTO set Stock = Stock -1 where IdProducto = @IdProducto
		insert into CARRITO(IdUsuario,IdProducto) values ( @IdUsuario,@IdProducto)
		set @Resultado = 1
	end
	
end

go

create proc sp_ObtenerCarrito(
@IdUsuario int
)
as
begin
	select c.IdCarrito, p.IdProducto,m.Descripcion,p.Nombre,p.Precio,p.RutaImagen from carrito c
	inner join PRODUCTO p on p.IdProducto = c.IdProducto
	inner join MARCA m on m.IdMarca = p.IdMarca
	where c.IdUsuario = @IdUsuario
end

go


create proc sp_registrarCompra(
@IdUsuario int,
@TotalProducto int,
@Total decimal(10,2),
@Contacto varchar(100),
@Telefono varchar(100),
@Direccion varchar(100),
@IdDistrito varchar(10),
@QueryDetalleCompra nvarchar(max),
@Resultado bit output
)
as
begin
	begin try
		SET @Resultado = 0
		begin transaction
		
		declare @idcompra int = 0
		insert into COMPRA(IdUsuario,TotalProducto,Total,Contacto,Telefono,Direccion,IdDistrito) values
		(@IdUsuario,@TotalProducto,@Total,@Contacto,@Telefono,@Direccion,@IdDistrito)

		set @idcompra = scope_identity()

		set @QueryDetalleCompra = replace(@QueryDetalleCompra,'¡idcompra!',@idcompra)

		EXECUTE sp_executesql @QueryDetalleCompra

		delete from CARRITO where IdUsuario = @IdUsuario

		SET @Resultado = 1

		commit
	end try
	begin catch
		rollback
		SET @Resultado = 0
	end catch
end

go

create proc sp_ObtenerCompra(
@IdUsuario int)
as
begin
select c.Total,convert(char(10),c.FechaCompra,103)[Fecha],

(select m.Descripcion, p.Nombre,p.RutaImagen,dc.Total,dc.Cantidad from DETALLE_COMPRA dc
inner join PRODUCTO p on p.IdProducto = dc.IdProducto
inner join MARCA m on m.IdMarca = p.IdMarca
where dc.IdCompra = c.IdCompra
FOR XML PATH ('PRODUCTO'),TYPE) AS 'DETALLE_PRODUCTO'

from compra c
where c.IdUsuario = @IdUsuario
FOR XML PATH('COMPRA'), ROOT('DATA') 
end

-- Insertado de Datos

go


insert into USUARIO(Nombres,Apellidos,Correo,Contrasena,EsAdministrador) values ('test','user','admin@example.com','admin123',1)

GO
insert into CATEGORIA(Descripcion) values
('Collares'),
('Pulseras'),
('Anillos'),
('Aretes'),
('Tobilleras'),
('Extras')

GO

insert into MARCA(Descripcion) values
('Atianas')

GO

INSERT INTO PRODUCTO(Nombre, Descripcion, IdMarca, IdCategoria, Precio, Stock, RutaImagen)
VALUES (
    'Anillo para Parejas en Forma de Corazon',
    'Un hermoso anillo diseñado para parejas, con un elegante diseño en forma de corazón. Fabricado con materiales de alta calidad, este anillo simboliza el amor y la unión. Ideal para aniversarios, compromisos o como muestra de amor.',
    1,
    3,
    '30',
    '50',
    '~/Imagenes/Productos/1.jpeg'
);

INSERT INTO PRODUCTO(Nombre, Descripcion, IdMarca, IdCategoria, Precio, Stock, RutaImagen)
VALUES (
    'Anillo para Parejas en Forma de Mariposa',
    'Este anillo para parejas presenta un delicado diseño de mariposa, simbolizando la transformación y la belleza. Elaborado con materiales de alta calidad, es perfecto para celebrar momentos especiales y demostrar el amor y la conexión entre dos personas. Ideal para regalos de aniversario, compromisos o simplemente para mostrar aprecio.',
    1,
    3,
    '30',
    '60',
    '~/Imagenes/Productos/2.jpeg'
);

INSERT INTO PRODUCTO(Nombre, Descripcion, IdMarca, IdCategoria, Precio, Stock, RutaImagen)
VALUES (
    'Pulsera de Perlas Doradas en Rojo y Negro',
    'Elegante pulsera con perlas doradas combinadas en rojo y negro, perfecta para añadir un toque de sofisticación a cualquier atuendo. Fabricada con materiales de alta calidad, esta pulsera es ideal para ocasiones especiales o como un regalo distintivo. Su diseño único y llamativo la convierte en una joya imprescindible en cualquier colección.',
    1,
    2,
    '20',
    '120',
    '~/Imagenes/Productos/3.jpeg'
);


INSERT INTO PRODUCTO(Nombre, Descripcion, IdMarca, IdCategoria, Precio, Stock, RutaImagen)
VALUES (
    'Pulsera de Cuarzo Rosa en Cascajo',
    'Hermosa pulsera de cuarzo rosa en cascajo, conocida por sus propiedades de amor y paz. Esta pulsera está cuidadosamente elaborada con fragmentos de cuarzo rosa, proporcionando un diseño único y natural. Ideal para complementar cualquier atuendo y como un regalo significativo para alguien especial. Perfecta para ocasiones especiales o uso diario.',
    1,
    2,
    '50',
    '70',
    '~/Imagenes/Productos/4.jpeg'
);

INSERT INTO PRODUCTO(Nombre, Descripcion, IdMarca, IdCategoria, Precio, Stock, RutaImagen)
VALUES (
    'Pulsera de Perlas Color Celeste Transparente',
    'Delicada pulsera de color celeste transparente, perfecta para añadir un toque de elegancia y frescura a cualquier atuendo. Fabricada con materiales de alta calidad, esta pulsera es ideal para ocasiones especiales o como un regalo elegante. Su diseño sutil y refinado la convierte en una joya versátil y atractiva para cualquier colección.',
    1,
    2,
    '30',
    '90',
    '~/Imagenes/Productos/5.jpeg'
);


INSERT INTO PRODUCTO(Nombre, Descripcion, IdMarca, IdCategoria, Precio, Stock, RutaImagen)
VALUES (
    'Pulsera de Perlas Color Rosa Transparente',
    'Encantadora pulsera de color rosa transparente, que añade un toque de delicadeza y feminidad a cualquier look. Esta pulsera está cuidadosamente diseñada para brindar elegancia y estilo. Ideal para ocasiones especiales o para el uso diario, esta joya será una adición deslumbrante a tu colección.',
    1,
    2,
    '30',
    '60',
    '~/Imagenes/Productos/6.jpeg'
);

INSERT INTO PRODUCTO(Nombre, Descripcion, IdMarca, IdCategoria, Precio, Stock, RutaImagen)
VALUES (
    'Pulsera de Perlas Color Verde Transparente',
    'Una pulsera encantadora en tonos verdes transparentes, que evoca la frescura y la vitalidad de la naturaleza. Su diseño sutil y elegante añade un toque de estilo a cualquier conjunto. Perfecta para ocasiones especiales o para el uso diario, esta pulsera será una adición vibrante a tu colección de joyas.',
    1,
    2,
    '30',
    '90',
    '~/Imagenes/Productos/7.jpeg'
);

INSERT INTO PRODUCTO(Nombre, Descripcion, IdMarca, IdCategoria, Precio, Stock, RutaImagen)
VALUES (
    'Pulsera de Perlas Color Morado Transparente',
    'Exquisita pulsera en tonos morados transparentes, que emana elegancia y misterio. Su diseño refinado y sofisticado complementa cualquier estilo con un toque de distinción. Perfecta para ocasiones especiales o para dar un toque de glamour a tu atuendo diario, esta pulsera se convertirá en el centro de atención de tu colección de joyas.',
    1,
    2,
    '30',
    '120',
    '~/Imagenes/Productos/8.jpeg'
);

INSERT INTO PRODUCTO(Nombre, Descripcion, IdMarca, IdCategoria, Precio, Stock, RutaImagen)
VALUES (
    'Pulsera de Perlas Color Celeste y Negro con Diseño de Grietas',
    'Una pulsera única que combina la elegancia de las perlas con un diseño moderno de grietas en tonos celestes y negros. Este diseño cautivador es perfecto para agregar un toque de sofisticación a cualquier atuendo. Ideal para ocasiones especiales o para complementar tu estilo diario con un toque de originalidad y estilo.',
    1,
    2,
    '40',
    '130',
    '~/Imagenes/Productos/9.jpeg'
);

INSERT INTO PRODUCTO(Nombre, Descripcion, IdMarca, IdCategoria, Precio, Stock, RutaImagen)
VALUES (
    'Pulsera de Perlas Color Ámbar con Diseño',
    'Una pulsera elegante y refinada con perlas en tonos ámbar, destacando su belleza única. Este diseño cautivador presenta un diseño sofisticado que complementará tu estilo con elegancia. Perfecto para ocasiones especiales o para añadir un toque de glamour a tu look diario, esta pulsera será el centro de atención de cualquier outfit.',
    1,
    2,
    '50',
    '60',
    '~/Imagenes/Productos/10.jpeg'
);

go


-- UBIGEOS
go


INSERT INTO DEPARTAMENTO(IdDepartamento, Descripcion) VALUES
('01', 'Amazonas'),
('02', 'Áncash'),
('03', 'Apurímac'),
('04', 'Arequipa'),
('05', 'Ayacucho'),
('06', 'Cajamarca'),
('07', 'Callao'),
('08', 'Cusco'),
('09', 'Huancavelica'),
('10', 'Huánuco'),
('11', 'Ica'),
('12', 'Junín'),
('13', 'La Libertad'),
('14', 'Lambayeque'),
('15', 'Lima'),
('16', 'Loreto'),
('17', 'Madre de Dios'),
('18', 'Moquegua'),
('19', 'Pasco'),
('20', 'Piura'),
('21', 'Puno'),
('22', 'San Martín'),
('23', 'Tacna'),
('24', 'Tumbes'),
('25', 'Ucayali')

go


INSERT INTO PROVINCIA(IdProvincia, Descripcion, IdDepartamento) VALUES
('0101', 'Chachapoyas', '01'),
('0102', 'Bagua', '01'),
('0103', 'Bongará', '01'),
('0104', 'Condorcanqui', '01'),
('0105', 'Luya', '01'),
('0106', 'Rodríguez de Mendoza', '01'),
('0107', 'Utcubamba', '01'),
('0201', 'Huaraz', '02'),
('0202', 'Aija', '02'),
('0203', 'Antonio Raymondi', '02'),
('0204', 'Asunción', '02'),
('0205', 'Bolognesi', '02'),
('0206', 'Carhuaz', '02'),
('0207', 'Carlos Fermín Fitzcarrald', '02'),
('0208', 'Casma', '02'),
('0209', 'Corongo', '02'),
('0210', 'Huari', '02'),
('0211', 'Huarmey', '02'),
('0212', 'Huaylas', '02'),
('0213', 'Mariscal Luzuriaga', '02'),
('0214', 'Ocros', '02'),
('0215', 'Pallasca', '02'),
('0216', 'Pomabamba', '02'),
('0217', 'Recuay', '02'),
('0218', 'Santa', '02'),
('0219', 'Sihuas', '02'),
('0220', 'Yungay', '02'),
('0301', 'Abancay', '03'),
('0302', 'Andahuaylas', '03'),
('0303', 'Antabamba', '03'),
('0304', 'Aymaraes', '03'),
('0305', 'Cotabambas', '03'),
('0306', 'Chincheros', '03'),
('0307', 'Grau', '03'),
('0401', 'Arequipa', '04'),
('0402', 'Camaná', '04'),
('0403', 'Caravelí', '04'),
('0404', 'Castilla', '04'),
('0405', 'Caylloma', '04'),
('0406', 'Condesuyos', '04'),
('0407', 'Islay', '04'),
('0408', 'La Uniòn', '04'),
('0501', 'Huamanga', '05'),
('0502', 'Cangallo', '05'),
('0503', 'Huanca Sancos', '05'),
('0504', 'Huanta', '05'),
('0505', 'La Mar', '05'),
('0506', 'Lucanas', '05'),
('0507', 'Parinacochas', '05'),
('0508', 'Pàucar del Sara Sara', '05'),
('0509', 'Sucre', '05'),
('0510', 'Víctor Fajardo', '05'),
('0511', 'Vilcas Huamán', '05'),
('0601', 'Cajamarca', '06'),
('0602', 'Cajabamba', '06'),
('0603', 'Celendín', '06'),
('0604', 'Chota', '06'),
('0605', 'Contumazá', '06'),
('0606', 'Cutervo', '06'),
('0607', 'Hualgayoc', '06'),
('0608', 'Jaén', '06'),
('0609', 'San Ignacio', '06'),
('0610', 'San Marcos', '06'),
('0611', 'San Miguel', '06'),
('0612', 'San Pablo', '06'),
('0613', 'Santa Cruz', '06'),
('0701', 'Prov. Const. del Callao', '07'),
('0801', 'Cusco', '08'),
('0802', 'Acomayo', '08'),
('0803', 'Anta', '08'),
('0804', 'Calca', '08'),
('0805', 'Canas', '08'),
('0806', 'Canchis', '08'),
('0807', 'Chumbivilcas', '08'),
('0808', 'Espinar', '08'),
('0809', 'La Convención', '08'),
('0810', 'Paruro', '08'),
('0811', 'Paucartambo', '08'),
('0812', 'Quispicanchi', '08'),
('0813', 'Urubamba', '08'),
('0901', 'Huancavelica', '09'),
('0902', 'Acobamba', '09'),
('0903', 'Angaraes', '09'),
('0904', 'Castrovirreyna', '09'),
('0905', 'Churcampa', '09'),
('0906', 'Huaytará', '09'),
('0907', 'Tayacaja', '09'),
('1001', 'Huánuco', '10'),
('1002', 'Ambo', '10'),
('1003', 'Dos de Mayo', '10'),
('1004', 'Huacaybamba', '10'),
('1005', 'Huamalíes', '10'),
('1006', 'Leoncio Prado', '10'),
('1007', 'Marañón', '10'),
('1008', 'Pachitea', '10'),
('1009', 'Puerto Inca', '10'),
('1010', 'Lauricocha ', '10'),
('1011', 'Yarowilca ', '10'),
('1101', 'Ica ', '11'),
('1102', 'Chincha ', '11'),
('1103', 'Nasca ', '11'),
('1104', 'Palpa ', '11'),
('1105', 'Pisco ', '11'),
('1201', 'Huancayo ', '12'),
('1202', 'Concepción ', '12'),
('1203', 'Chanchamayo ', '12'),
('1204', 'Jauja ', '12'),
('1205', 'Junín ', '12'),
('1206', 'Satipo ', '12'),
('1207', 'Tarma ', '12'),
('1208', 'Yauli ', '12'),
('1209', 'Chupaca ', '12'),
('1301', 'Trujillo ', '13'),
('1302', 'Ascope ', '13'),
('1303', 'Bolívar ', '13'),
('1304', 'Chepén ', '13'),
('1305', 'Julcán ', '13'),
('1306', 'Otuzco ', '13'),
('1307', 'Pacasmayo ', '13'),
('1308', 'Pataz ', '13'),
('1309', 'Sánchez Carrión ', '13'),
('1310', 'Santiago de Chuco ', '13'),
('1311', 'Gran Chimú ', '13'),
('1312', 'Virú ', '13'),
('1401', 'Chiclayo ', '14'),
('1402', 'Ferreñafe ', '14'),
('1403', 'Lambayeque ', '14'),
('1501', 'Lima ', '15'),
('1502', 'Barranca ', '15'),
('1503', 'Cajatambo ', '15'),
('1504', 'Canta ', '15'),
('1505', 'Cañete ', '15'),
('1506', 'Huaral ', '15'),
('1507', 'Huarochirí ', '15'),
('1508', 'Huaura ', '15'),
('1509', 'Oyón ', '15'),
('1510', 'Yauyos ', '15'),
('1601', 'Maynas ', '16'),
('1602', 'Alto Amazonas ', '16'),
('1603', 'Loreto ', '16'),
('1604', 'Mariscal Ramón Castilla ', '16'),
('1605', 'Requena ', '16'),
('1606', 'Ucayali ', '16'),
('1607', 'Datem del Marañón ', '16'),
('1608', 'Putumayo', '16'),
('1701', 'Tambopata ', '17'),
('1702', 'Manu ', '17'),
('1703', 'Tahuamanu ', '17'),
('1801', 'Mariscal Nieto ', '18'),
('1802', 'General Sánchez Cerro ', '18'),
('1803', 'Ilo ', '18'),
('1901', 'Pasco ', '19'),
('1902', 'Daniel Alcides Carrión ', '19'),
('1903', 'Oxapampa ', '19'),
('2001', 'Piura ', '20'),
('2002', 'Ayabaca ', '20'),
('2003', 'Huancabamba ', '20'),
('2004', 'Morropón ', '20'),
('2005', 'Paita ', '20'),
('2006', 'Sullana ', '20'),
('2007', 'Talara ', '20'),
('2008', 'Sechura ', '20'),
('2101', 'Puno ', '21'),
('2102', 'Azángaro ', '21'),
('2103', 'Carabaya ', '21'),
('2104', 'Chucuito ', '21'),
('2105', 'El Collao ', '21'),
('2106', 'Huancané ', '21'),
('2107', 'Lampa ', '21'),
('2108', 'Melgar ', '21'),
('2109', 'Moho ', '21'),
('2110', 'San Antonio de Putina ', '21'),
('2111', 'San Román ', '21'),
('2112', 'Sandia ', '21'),
('2113', 'Yunguyo ', '21'),
('2201', 'Moyobamba ', '22'),
('2202', 'Bellavista ', '22'),
('2203', 'El Dorado ', '22'),
('2204', 'Huallaga ', '22'),
('2205', 'Lamas ', '22'),
('2206', 'Mariscal Cáceres ', '22'),
('2207', 'Picota ', '22'),
('2208', 'Rioja ', '22'),
('2209', 'San Martín ', '22'),
('2210', 'Tocache ', '22'),
('2301', 'Tacna ', '23'),
('2302', 'Candarave ', '23'),
('2303', 'Jorge Basadre ', '23'),
('2304', 'Tarata ', '23'),
('2401', 'Tumbes ', '24'),
('2402', 'Contralmirante Villar ', '24'),
('2403', 'Zarumilla ', '24'),
('2501', 'Coronel Portillo ', '25'),
('2502', 'Atalaya ', '25'),
('2503', 'Padre Abad ', '25'),
('2504', 'Purús', '25')


go



INSERT INTO DISTRITO (IdDistrito, Descripcion, IdProvincia, IdDepartamento) VALUES
('010101', 'Chachapoyas', '0101', '01'),
('010102', 'Asunción', '0101', '01'),
('010103', 'Balsas', '0101', '01'),
('010104', 'Cheto', '0101', '01'),
('010105', 'Chiliquin', '0101', '01'),
('010106', 'Chuquibamba', '0101', '01'),
('010107', 'Granada', '0101', '01'),
('010108', 'Huancas', '0101', '01'),
('010109', 'La Jalca', '0101', '01'),
('010110', 'Leimebamba', '0101', '01'),
('010111', 'Levanto', '0101', '01'),
('010112', 'Magdalena', '0101', '01'),
('010113', 'Mariscal Castilla', '0101', '01'),
('010114', 'Molinopampa', '0101', '01'),
('010115', 'Montevideo', '0101', '01'),
('010116', 'Olleros', '0101', '01'),
('010117', 'Quinjalca', '0101', '01'),
('010118', 'San Francisco de Daguas', '0101', '01'),
('010119', 'San Isidro de Maino', '0101', '01'),
('010120', 'Soloco', '0101', '01'),
('010121', 'Sonche', '0101', '01'),
('010201', 'Bagua', '0102', '01'),
('010202', 'Aramango', '0102', '01'),
('010203', 'Copallin', '0102', '01'),
('010204', 'El Parco', '0102', '01'),
('010205', 'Imaza', '0102', '01'),
('010206', 'La Peca', '0102', '01'),
('010301', 'Jumbilla', '0103', '01'),
('010302', 'Chisquilla', '0103', '01'),
('010303', 'Churuja', '0103', '01'),
('010304', 'Corosha', '0103', '01'),
('010305', 'Cuispes', '0103', '01'),
('010306', 'Florida', '0103', '01'),
('010307', 'Jazan', '0103', '01'),
('010308', 'Recta', '0103', '01'),
('010309', 'San Carlos', '0103', '01'),
('010310', 'Shipasbamba', '0103', '01'),
('010311', 'Valera', '0103', '01'),
('010312', 'Yambrasbamba', '0103', '01'),
('010401', 'Nieva', '0104', '01'),
('010402', 'El Cenepa', '0104', '01'),
('010403', 'Río Santiago', '0104', '01'),
('010501', 'Lamud', '0105', '01'),
('010502', 'Camporredondo', '0105', '01'),
('010503', 'Cocabamba', '0105', '01'),
('010504', 'Colcamar', '0105', '01'),
('010505', 'Conila', '0105', '01'),
('010506', 'Inguilpata', '0105', '01'),
('010507', 'Longuita', '0105', '01'),
('010508', 'Lonya Chico', '0105', '01'),
('010509', 'Luya', '0105', '01'),
('010510', 'Luya Viejo', '0105', '01'),
('010511', 'María', '0105', '01'),
('010512', 'Ocalli', '0105', '01'),
('010513', 'Ocumal', '0105', '01'),
('010514', 'Pisuquia', '0105', '01'),
('010515', 'Providencia', '0105', '01'),
('010516', 'San Cristóbal', '0105', '01'),
('010517', 'San Francisco de Yeso', '0105', '01'),
('010518', 'San Jerónimo', '0105', '01'),
('010519', 'San Juan de Lopecancha', '0105', '01'),
('010520', 'Santa Catalina', '0105', '01'),
('010521', 'Santo Tomas', '0105', '01'),
('010522', 'Tingo', '0105', '01'),
('010523', 'Trita', '0105', '01'),
('010601', 'San Nicolás', '0106', '01'),
('010602', 'Chirimoto', '0106', '01'),
('010603', 'Cochamal', '0106', '01'),
('010604', 'Huambo', '0106', '01'),
('010605', 'Limabamba', '0106', '01'),
('010606', 'Longar', '0106', '01'),
('010607', 'Mariscal Benavides', '0106', '01'),
('010608', 'Milpuc', '0106', '01'),
('010609', 'Omia', '0106', '01'),
('010610', 'Santa Rosa', '0106', '01'),
('010611', 'Totora', '0106', '01'),
('010612', 'Vista Alegre', '0106', '01'),
('010701', 'Bagua Grande', '0107', '01'),
('010702', 'Cajaruro', '0107', '01'),
('010703', 'Cumba', '0107', '01'),
('010704', 'El Milagro', '0107', '01'),
('010705', 'Jamalca', '0107', '01'),
('010706', 'Lonya Grande', '0107', '01'),
('010707', 'Yamon', '0107', '01'),
('020101', 'Huaraz', '0201', '02'),
('020102', 'Cochabamba', '0201', '02'),
('020103', 'Colcabamba', '0201', '02'),
('020104', 'Huanchay', '0201', '02'),
('020105', 'Independencia', '0201', '02'),
('020106', 'Jangas', '0201', '02'),
('020107', 'La Libertad', '0201', '02'),
('020108', 'Olleros', '0201', '02'),
('020109', 'Pampas Grande', '0201', '02'),
('020110', 'Pariacoto', '0201', '02'),
('020111', 'Pira', '0201', '02'),
('020112', 'Tarica', '0201', '02'),
('020201', 'Aija', '0202', '02'),
('020202', 'Coris', '0202', '02'),
('020203', 'Huacllan', '0202', '02'),
('020204', 'La Merced', '0202', '02'),
('020205', 'Succha', '0202', '02'),
('020301', 'Llamellin', '0203', '02'),
('020302', 'Aczo', '0203', '02'),
('020303', 'Chaccho', '0203', '02'),
('020304', 'Chingas', '0203', '02'),
('020305', 'Mirgas', '0203', '02'),
('020306', 'San Juan de Rontoy', '0203', '02'),
('020401', 'Chacas', '0204', '02'),
('020402', 'Acochaca', '0204', '02'),
('020501', 'Chiquian', '0205', '02'),
('020502', 'Abelardo Pardo Lezameta', '0205', '02'),
('020503', 'Antonio Raymondi', '0205', '02'),
('020504', 'Aquia', '0205', '02'),
('020505', 'Cajacay', '0205', '02'),
('020506', 'Canis', '0205', '02'),
('020507', 'Colquioc', '0205', '02'),
('020508', 'Huallanca', '0205', '02'),
('020509', 'Huasta', '0205', '02'),
('020510', 'Huayllacayan', '0205', '02'),
('020511', 'La Primavera', '0205', '02'),
('020512', 'Mangas', '0205', '02'),
('020513', 'Pacllon', '0205', '02'),
('020514', 'San Miguel de Corpanqui', '0205', '02'),
('020515', 'Ticllos', '0205', '02'),
('020601', 'Carhuaz', '0206', '02'),
('020602', 'Acopampa', '0206', '02'),
('020603', 'Amashca', '0206', '02'),
('020604', 'Anta', '0206', '02'),
('020605', 'Ataquero', '0206', '02'),
('020606', 'Marcara', '0206', '02'),
('020607', 'Pariahuanca', '0206', '02'),
('020608', 'San Miguel de Aco', '0206', '02'),
('020609', 'Shilla', '0206', '02'),
('020610', 'Tinco', '0206', '02'),
('020611', 'Yungar', '0206', '02'),
('020701', 'San Luis', '0207', '02'),
('020702', 'San Nicolás', '0207', '02'),
('020703', 'Yauya', '0207', '02'),
('020801', 'Casma', '0208', '02'),
('020802', 'Buena Vista Alta', '0208', '02'),
('020803', 'Comandante Noel', '0208', '02'),
('020804', 'Yautan', '0208', '02'),
('020901', 'Corongo', '0209', '02'),
('020902', 'Aco', '0209', '02'),
('020903', 'Bambas', '0209', '02'),
('020904', 'Cusca', '0209', '02'),
('020905', 'La Pampa', '0209', '02'),
('020906', 'Yanac', '0209', '02'),
('020907', 'Yupan', '0209', '02'),
('021001', 'Huari', '0210', '02'),
('021002', 'Anra', '0210', '02'),
('021003', 'Cajay', '0210', '02'),
('021004', 'Chavin de Huantar', '0210', '02'),
('021005', 'Huacachi', '0210', '02'),
('021006', 'Huacchis', '0210', '02'),
('021007', 'Huachis', '0210', '02'),
('021008', 'Huantar', '0210', '02'),
('021009', 'Masin', '0210', '02'),
('021010', 'Paucas', '0210', '02'),
('021011', 'Ponto', '0210', '02'),
('021012', 'Rahuapampa', '0210', '02'),
('021013', 'Rapayan', '0210', '02'),
('021014', 'San Marcos', '0210', '02'),
('021015', 'San Pedro de Chana', '0210', '02'),
('021016', 'Uco', '0210', '02'),
('021101', 'Huarmey', '0211', '02'),
('021102', 'Cochapeti', '0211', '02'),
('021103', 'Culebras', '0211', '02'),
('021104', 'Huayan', '0211', '02'),
('021105', 'Malvas', '0211', '02'),
('021201', 'Caraz', '0212', '02'),
('021202', 'Huallanca', '0212', '02'),
('021203', 'Huata', '0212', '02'),
('021204', 'Huaylas', '0212', '02'),
('021205', 'Mato', '0212', '02'),
('021206', 'Pamparomas', '0212', '02'),
('021207', 'Pueblo Libre', '0212', '02'),
('021208', 'Santa Cruz', '0212', '02'),
('021209', 'Santo Toribio', '0212', '02'),
('021210', 'Yuracmarca', '0212', '02'),
('021301', 'Piscobamba', '0213', '02'),
('021302', 'Casca', '0213', '02'),
('021303', 'Eleazar Guzmán Barron', '0213', '02'),
('021304', 'Fidel Olivas Escudero', '0213', '02'),
('021305', 'Llama', '0213', '02'),
('021306', 'Llumpa', '0213', '02'),
('021307', 'Lucma', '0213', '02'),
('021308', 'Musga', '0213', '02'),
('021401', 'Ocros', '0214', '02'),
('021402', 'Acas', '0214', '02'),
('021403', 'Cajamarquilla', '0214', '02'),
('021404', 'Carhuapampa', '0214', '02'),
('021405', 'Cochas', '0214', '02'),
('021406', 'Congas', '0214', '02'),
('021407', 'Llipa', '0214', '02'),
('021408', 'San Cristóbal de Rajan', '0214', '02'),
('021409', 'San Pedro', '0214', '02'),
('021410', 'Santiago de Chilcas', '0214', '02'),
('021501', 'Cabana', '0215', '02'),
('021502', 'Bolognesi', '0215', '02'),
('021503', 'Conchucos', '0215', '02'),
('021504', 'Huacaschuque', '0215', '02'),
('021505', 'Huandoval', '0215', '02'),
('021506', 'Lacabamba', '0215', '02'),
('021507', 'Llapo', '0215', '02'),
('021508', 'Pallasca', '0215', '02'),
('021509', 'Pampas', '0215', '02'),
('021510', 'Santa Rosa', '0215', '02'),
('021511', 'Tauca', '0215', '02'),
('021601', 'Pomabamba', '0216', '02'),
('021602', 'Huayllan', '0216', '02'),
('021603', 'Parobamba', '0216', '02'),
('021604', 'Quinuabamba', '0216', '02'),
('021701', 'Recuay', '0217', '02'),
('021702', 'Catac', '0217', '02'),
('021703', 'Cotaparaco', '0217', '02'),
('021704', 'Huayllapampa', '0217', '02'),
('021705', 'Llacllin', '0217', '02'),
('021706', 'Marca', '0217', '02'),
('021707', 'Pampas Chico', '0217', '02'),
('021708', 'Pararin', '0217', '02'),
('021709', 'Tapacocha', '0217', '02'),
('021710', 'Ticapampa', '0217', '02'),
('021801', 'Chimbote', '0218', '02'),
('021802', 'Cáceres del Perú', '0218', '02'),
('021803', 'Coishco', '0218', '02'),
('021804', 'Macate', '0218', '02'),
('021805', 'Moro', '0218', '02'),
('021806', 'Nepeña', '0218', '02'),
('021807', 'Samanco', '0218', '02'),
('021808', 'Santa', '0218', '02'),
('021809', 'Nuevo Chimbote', '0218', '02'),
('021901', 'Sihuas', '0219', '02'),
('021902', 'Acobamba', '0219', '02'),
('021903', 'Alfonso Ugarte', '0219', '02'),
('021904', 'Cashapampa', '0219', '02'),
('021905', 'Chingalpo', '0219', '02'),
('021906', 'Huayllabamba', '0219', '02'),
('021907', 'Quiches', '0219', '02'),
('021908', 'Ragash', '0219', '02'),
('021909', 'San Juan', '0219', '02'),
('021910', 'Sicsibamba', '0219', '02'),
('022001', 'Yungay', '0220', '02'),
('022002', 'Cascapara', '0220', '02'),
('022003', 'Mancos', '0220', '02'),
('022004', 'Matacoto', '0220', '02'),
('022005', 'Quillo', '0220', '02'),
('022006', 'Ranrahirca', '0220', '02'),
('022007', 'Shupluy', '0220', '02'),
('022008', 'Yanama', '0220', '02'),
('030101', 'Abancay', '0301', '03'),
('030102', 'Chacoche', '0301', '03'),
('030103', 'Circa', '0301', '03'),
('030104', 'Curahuasi', '0301', '03'),
('030105', 'Huanipaca', '0301', '03'),
('030106', 'Lambrama', '0301', '03'),
('030107', 'Pichirhua', '0301', '03'),
('030108', 'San Pedro de Cachora', '0301', '03'),
('030109', 'Tamburco', '0301', '03'),
('030201', 'Andahuaylas', '0302', '03'),
('030202', 'Andarapa', '0302', '03'),
('030203', 'Chiara', '0302', '03'),
('030204', 'Huancarama', '0302', '03'),
('030205', 'Huancaray', '0302', '03'),
('030206', 'Huayana', '0302', '03'),
('030207', 'Kishuara', '0302', '03'),
('030208', 'Pacobamba', '0302', '03'),
('030209', 'Pacucha', '0302', '03'),
('030210', 'Pampachiri', '0302', '03'),
('030211', 'Pomacocha', '0302', '03'),
('030212', 'San Antonio de Cachi', '0302', '03'),
('030213', 'San Jerónimo', '0302', '03'),
('030214', 'San Miguel de Chaccrampa', '0302', '03'),
('030215', 'Santa María de Chicmo', '0302', '03'),
('030216', 'Talavera', '0302', '03'),
('030217', 'Tumay Huaraca', '0302', '03'),
('030218', 'Turpo', '0302', '03'),
('030219', 'Kaquiabamba', '0302', '03'),
('030220', 'José María Arguedas', '0302', '03'),
('030301', 'Antabamba', '0303', '03'),
('030302', 'El Oro', '0303', '03'),
('030303', 'Huaquirca', '0303', '03'),
('030304', 'Juan Espinoza Medrano', '0303', '03'),
('030305', 'Oropesa', '0303', '03'),
('030306', 'Pachaconas', '0303', '03'),
('030307', 'Sabaino', '0303', '03'),
('030401', 'Chalhuanca', '0304', '03'),
('030402', 'Capaya', '0304', '03'),
('030403', 'Caraybamba', '0304', '03'),
('030404', 'Chapimarca', '0304', '03'),
('030405', 'Colcabamba', '0304', '03'),
('030406', 'Cotaruse', '0304', '03'),
('030407', 'Ihuayllo', '0304', '03'),
('030408', 'Justo Apu Sahuaraura', '0304', '03'),
('030409', 'Lucre', '0304', '03'),
('030410', 'Pocohuanca', '0304', '03'),
('030411', 'San Juan de Chacña', '0304', '03'),
('030412', 'Sañayca', '0304', '03'),
('030413', 'Soraya', '0304', '03'),
('030414', 'Tapairihua', '0304', '03'),
('030415', 'Tintay', '0304', '03'),
('030416', 'Toraya', '0304', '03'),
('030417', 'Yanaca', '0304', '03'),
('030501', 'Tambobamba', '0305', '03'),
('030502', 'Cotabambas', '0305', '03'),
('030503', 'Coyllurqui', '0305', '03'),
('030504', 'Haquira', '0305', '03'),
('030505', 'Mara', '0305', '03'),
('030506', 'Challhuahuacho', '0305', '03'),
('030601', 'Chincheros', '0306', '03'),
('030602', 'Anco_Huallo', '0306', '03'),
('030603', 'Cocharcas', '0306', '03'),
('030604', 'Huaccana', '0306', '03'),
('030605', 'Ocobamba', '0306', '03'),
('030606', 'Ongoy', '0306', '03'),
('030607', 'Uranmarca', '0306', '03'),
('030608', 'Ranracancha', '0306', '03'),
('030609', 'Rocchacc', '0306', '03'),
('030610', 'El Porvenir', '0306', '03'),
('030611', 'Los Chankas', '0306', '03'),
('030701', 'Chuquibambilla', '0307', '03'),
('030702', 'Curpahuasi', '0307', '03'),
('030703', 'Gamarra', '0307', '03'),
('030704', 'Huayllati', '0307', '03'),
('030705', 'Mamara', '0307', '03'),
('030706', 'Micaela Bastidas', '0307', '03'),
('030707', 'Pataypampa', '0307', '03'),
('030708', 'Progreso', '0307', '03'),
('030709', 'San Antonio', '0307', '03'),
('030710', 'Santa Rosa', '0307', '03'),
('030711', 'Turpay', '0307', '03'),
('030712', 'Vilcabamba', '0307', '03'),
('030713', 'Virundo', '0307', '03'),
('030714', 'Curasco', '0307', '03'),
('040101', 'Arequipa', '0401', '04'),
('040102', 'Alto Selva Alegre', '0401', '04'),
('040103', 'Cayma', '0401', '04'),
('040104', 'Cerro Colorado', '0401', '04'),
('040105', 'Characato', '0401', '04'),
('040106', 'Chiguata', '0401', '04'),
('040107', 'Jacobo Hunter', '0401', '04'),
('040108', 'La Joya', '0401', '04'),
('040109', 'Mariano Melgar', '0401', '04'),
('040110', 'Miraflores', '0401', '04'),
('040111', 'Mollebaya', '0401', '04'),
('040112', 'Paucarpata', '0401', '04'),
('040113', 'Pocsi', '0401', '04'),
('040114', 'Polobaya', '0401', '04'),
('040115', 'Quequeña', '0401', '04'),
('040116', 'Sabandia', '0401', '04'),
('040117', 'Sachaca', '0401', '04'),
('040118', 'San Juan de Siguas', '0401', '04'),
('040119', 'San Juan de Tarucani', '0401', '04'),
('040120', 'Santa Isabel de Siguas', '0401', '04'),
('040121', 'Santa Rita de Siguas', '0401', '04'),
('040122', 'Socabaya', '0401', '04'),
('040123', 'Tiabaya', '0401', '04'),
('040124', 'Uchumayo', '0401', '04'),
('040125', 'Vitor', '0401', '04'),
('040126', 'Yanahuara', '0401', '04'),
('040127', 'Yarabamba', '0401', '04'),
('040128', 'Yura', '0401', '04'),
('040129', 'José Luis Bustamante Y Rivero', '0401', '04'),
('040201', 'Camaná', '0402', '04'),
('040202', 'José María Quimper', '0402', '04'),
('040203', 'Mariano Nicolás Valcárcel', '0402', '04'),
('040204', 'Mariscal Cáceres', '0402', '04'),
('040205', 'Nicolás de Pierola', '0402', '04'),
('040206', 'Ocoña', '0402', '04'),
('040207', 'Quilca', '0402', '04'),
('040208', 'Samuel Pastor', '0402', '04'),
('040301', 'Caravelí', '0403', '04'),
('040302', 'Acarí', '0403', '04'),
('040303', 'Atico', '0403', '04'),
('040304', 'Atiquipa', '0403', '04'),
('040305', 'Bella Unión', '0403', '04'),
('040306', 'Cahuacho', '0403', '04'),
('040307', 'Chala', '0403', '04'),
('040308', 'Chaparra', '0403', '04'),
('040309', 'Huanuhuanu', '0403', '04'),
('040310', 'Jaqui', '0403', '04'),
('040311', 'Lomas', '0403', '04'),
('040312', 'Quicacha', '0403', '04'),
('040313', 'Yauca', '0403', '04'),
('040401', 'Aplao', '0404', '04'),
('040402', 'Andagua', '0404', '04'),
('040403', 'Ayo', '0404', '04'),
('040404', 'Chachas', '0404', '04'),
('040405', 'Chilcaymarca', '0404', '04'),
('040406', 'Choco', '0404', '04'),
('040407', 'Huancarqui', '0404', '04'),
('040408', 'Machaguay', '0404', '04'),
('040409', 'Orcopampa', '0404', '04'),
('040410', 'Pampacolca', '0404', '04'),
('040411', 'Tipan', '0404', '04'),
('040412', 'Uñon', '0404', '04'),
('040413', 'Uraca', '0404', '04'),
('040414', 'Viraco', '0404', '04'),
('040501', 'Chivay', '0405', '04'),
('040502', 'Achoma', '0405', '04'),
('040503', 'Cabanaconde', '0405', '04'),
('040504', 'Callalli', '0405', '04'),
('040505', 'Caylloma', '0405', '04'),
('040506', 'Coporaque', '0405', '04'),
('040507', 'Huambo', '0405', '04'),
('040508', 'Huanca', '0405', '04'),
('040509', 'Ichupampa', '0405', '04'),
('040510', 'Lari', '0405', '04'),
('040511', 'Lluta', '0405', '04'),
('040512', 'Maca', '0405', '04'),
('040513', 'Madrigal', '0405', '04'),
('040514', 'San Antonio de Chuca', '0405', '04'),
('040515', 'Sibayo', '0405', '04'),
('040516', 'Tapay', '0405', '04'),
('040517', 'Tisco', '0405', '04'),
('040518', 'Tuti', '0405', '04'),
('040519', 'Yanque', '0405', '04'),
('040520', 'Majes', '0405', '04'),
('040601', 'Chuquibamba', '0406', '04'),
('040602', 'Andaray', '0406', '04'),
('040603', 'Cayarani', '0406', '04'),
('040604', 'Chichas', '0406', '04'),
('040605', 'Iray', '0406', '04'),
('040606', 'Río Grande', '0406', '04'),
('040607', 'Salamanca', '0406', '04'),
('040608', 'Yanaquihua', '0406', '04'),
('040701', 'Mollendo', '0407', '04'),
('040702', 'Cocachacra', '0407', '04'),
('040703', 'Dean Valdivia', '0407', '04'),
('040704', 'Islay', '0407', '04'),
('040705', 'Mejia', '0407', '04'),
('040706', 'Punta de Bombón', '0407', '04'),
('040801', 'Cotahuasi', '0408', '04'),
('040802', 'Alca', '0408', '04'),
('040803', 'Charcana', '0408', '04'),
('040804', 'Huaynacotas', '0408', '04'),
('040805', 'Pampamarca', '0408', '04'),
('040806', 'Puyca', '0408', '04'),
('040807', 'Quechualla', '0408', '04'),
('040808', 'Sayla', '0408', '04'),
('040809', 'Tauria', '0408', '04'),
('040810', 'Tomepampa', '0408', '04'),
('040811', 'Toro', '0408', '04'),
('050101', 'Ayacucho', '0501', '05'),
('050102', 'Acocro', '0501', '05'),
('050103', 'Acos Vinchos', '0501', '05'),
('050104', 'Carmen Alto', '0501', '05'),
('050105', 'Chiara', '0501', '05'),
('050106', 'Ocros', '0501', '05'),
('050107', 'Pacaycasa', '0501', '05'),
('050108', 'Quinua', '0501', '05'),
('050109', 'San José de Ticllas', '0501', '05'),
('050110', 'San Juan Bautista', '0501', '05'),
('050111', 'Santiago de Pischa', '0501', '05'),
('050112', 'Socos', '0501', '05'),
('050113', 'Tambillo', '0501', '05'),
('050114', 'Vinchos', '0501', '05'),
('050115', 'Jesús Nazareno', '0501', '05'),
('050116', 'Andrés Avelino Cáceres Dorregaray', '0501', '05'),
('050201', 'Cangallo', '0502', '05'),
('050202', 'Chuschi', '0502', '05'),
('050203', 'Los Morochucos', '0502', '05'),
('050204', 'María Parado de Bellido', '0502', '05'),
('050205', 'Paras', '0502', '05'),
('050206', 'Totos', '0502', '05'),
('050301', 'Sancos', '0503', '05'),
('050302', 'Carapo', '0503', '05'),
('050303', 'Sacsamarca', '0503', '05'),
('050304', 'Santiago de Lucanamarca', '0503', '05'),
('050401', 'Huanta', '0504', '05'),
('050402', 'Ayahuanco', '0504', '05'),
('050403', 'Huamanguilla', '0504', '05'),
('050404', 'Iguain', '0504', '05'),
('050405', 'Luricocha', '0504', '05'),
('050406', 'Santillana', '0504', '05'),
('050407', 'Sivia', '0504', '05'),
('050408', 'Llochegua', '0504', '05'),
('050409', 'Canayre', '0504', '05'),
('050410', 'Uchuraccay', '0504', '05'),
('050411', 'Pucacolpa', '0504', '05'),
('050412', 'Chaca', '0504', '05'),
('050501', 'San Miguel', '0505', '05'),
('050502', 'Anco', '0505', '05'),
('050503', 'Ayna', '0505', '05'),
('050504', 'Chilcas', '0505', '05'),
('050505', 'Chungui', '0505', '05'),
('050506', 'Luis Carranza', '0505', '05'),
('050507', 'Santa Rosa', '0505', '05'),
('050508', 'Tambo', '0505', '05'),
('050509', 'Samugari', '0505', '05'),
('050510', 'Anchihuay', '0505', '05'),
('050511', 'Oronccoy', '0505', '05'),
('050601', 'Puquio', '0506', '05'),
('050602', 'Aucara', '0506', '05'),
('050603', 'Cabana', '0506', '05'),
('050604', 'Carmen Salcedo', '0506', '05'),
('050605', 'Chaviña', '0506', '05'),
('050606', 'Chipao', '0506', '05'),
('050607', 'Huac-Huas', '0506', '05'),
('050608', 'Laramate', '0506', '05'),
('050609', 'Leoncio Prado', '0506', '05'),
('050610', 'Llauta', '0506', '05'),
('050611', 'Lucanas', '0506', '05'),
('050612', 'Ocaña', '0506', '05'),
('050613', 'Otoca', '0506', '05'),
('050614', 'Saisa', '0506', '05'),
('050615', 'San Cristóbal', '0506', '05'),
('050616', 'San Juan', '0506', '05'),
('050617', 'San Pedro', '0506', '05'),
('050618', 'San Pedro de Palco', '0506', '05'),
('050619', 'Sancos', '0506', '05'),
('050620', 'Santa Ana de Huaycahuacho', '0506', '05'),
('050621', 'Santa Lucia', '0506', '05'),
('050701', 'Coracora', '0507', '05'),
('050702', 'Chumpi', '0507', '05'),
('050703', 'Coronel Castañeda', '0507', '05'),
('050704', 'Pacapausa', '0507', '05'),
('050705', 'Pullo', '0507', '05'),
('050706', 'Puyusca', '0507', '05'),
('050707', 'San Francisco de Ravacayco', '0507', '05'),
('050708', 'Upahuacho', '0507', '05'),
('050801', 'Pausa', '0508', '05'),
('050802', 'Colta', '0508', '05'),
('050803', 'Corculla', '0508', '05'),
('050804', 'Lampa', '0508', '05'),
('050805', 'Marcabamba', '0508', '05'),
('050806', 'Oyolo', '0508', '05'),
('050807', 'Pararca', '0508', '05'),
('050808', 'San Javier de Alpabamba', '0508', '05'),
('050809', 'San José de Ushua', '0508', '05'),
('050810', 'Sara Sara', '0508', '05'),
('050901', 'Querobamba', '0509', '05'),
('050902', 'Belén', '0509', '05'),
('050903', 'Chalcos', '0509', '05'),
('050904', 'Chilcayoc', '0509', '05'),
('050905', 'Huacaña', '0509', '05'),
('050906', 'Morcolla', '0509', '05'),
('050907', 'Paico', '0509', '05'),
('050908', 'San Pedro de Larcay', '0509', '05'),
('050909', 'San Salvador de Quije', '0509', '05'),
('050910', 'Santiago de Paucaray', '0509', '05'),
('050911', 'Soras', '0509', '05'),
('051001', 'Huancapi', '0510', '05'),
('051002', 'Alcamenca', '0510', '05'),
('051003', 'Apongo', '0510', '05'),
('051004', 'Asquipata', '0510', '05'),
('051005', 'Canaria', '0510', '05'),
('051006', 'Cayara', '0510', '05'),
('051007', 'Colca', '0510', '05'),
('051008', 'Huamanquiquia', '0510', '05'),
('051009', 'Huancaraylla', '0510', '05'),
('051010', 'Hualla', '0510', '05'),
('051011', 'Sarhua', '0510', '05'),
('051012', 'Vilcanchos', '0510', '05'),
('051101', 'Vilcas Huaman', '0511', '05'),
('051102', 'Accomarca', '0511', '05'),
('051103', 'Carhuanca', '0511', '05'),
('051104', 'Concepción', '0511', '05'),
('051105', 'Huambalpa', '0511', '05'),
('051106', 'Independencia', '0511', '05'),
('051107', 'Saurama', '0511', '05'),
('051108', 'Vischongo', '0511', '05'),
('060101', 'Cajamarca', '0601', '06'),
('060102', 'Asunción', '0601', '06'),
('060103', 'Chetilla', '0601', '06'),
('060104', 'Cospan', '0601', '06'),
('060105', 'Encañada', '0601', '06'),
('060106', 'Jesús', '0601', '06'),
('060107', 'Llacanora', '0601', '06'),
('060108', 'Los Baños del Inca', '0601', '06'),
('060109', 'Magdalena', '0601', '06'),
('060110', 'Matara', '0601', '06'),
('060111', 'Namora', '0601', '06'),
('060112', 'San Juan', '0601', '06'),
('060201', 'Cajabamba', '0602', '06'),
('060202', 'Cachachi', '0602', '06'),
('060203', 'Condebamba', '0602', '06'),
('060204', 'Sitacocha', '0602', '06'),
('060301', 'Celendín', '0603', '06'),
('060302', 'Chumuch', '0603', '06'),
('060303', 'Cortegana', '0603', '06'),
('060304', 'Huasmin', '0603', '06'),
('060305', 'Jorge Chávez', '0603', '06'),
('060306', 'José Gálvez', '0603', '06'),
('060307', 'Miguel Iglesias', '0603', '06'),
('060308', 'Oxamarca', '0603', '06'),
('060309', 'Sorochuco', '0603', '06'),
('060310', 'Sucre', '0603', '06'),
('060311', 'Utco', '0603', '06'),
('060312', 'La Libertad de Pallan', '0603', '06'),
('060401', 'Chota', '0604', '06'),
('060402', 'Anguia', '0604', '06'),
('060403', 'Chadin', '0604', '06'),
('060404', 'Chiguirip', '0604', '06'),
('060405', 'Chimban', '0604', '06'),
('060406', 'Choropampa', '0604', '06'),
('060407', 'Cochabamba', '0604', '06'),
('060408', 'Conchan', '0604', '06'),
('060409', 'Huambos', '0604', '06'),
('060410', 'Lajas', '0604', '06'),
('060411', 'Llama', '0604', '06'),
('060412', 'Miracosta', '0604', '06'),
('060413', 'Paccha', '0604', '06'),
('060414', 'Pion', '0604', '06'),
('060415', 'Querocoto', '0604', '06'),
('060416', 'San Juan de Licupis', '0604', '06'),
('060417', 'Tacabamba', '0604', '06'),
('060418', 'Tocmoche', '0604', '06'),
('060419', 'Chalamarca', '0604', '06'),
('060501', 'Contumaza', '0605', '06'),
('060502', 'Chilete', '0605', '06'),
('060503', 'Cupisnique', '0605', '06'),
('060504', 'Guzmango', '0605', '06'),
('060505', 'San Benito', '0605', '06'),
('060506', 'Santa Cruz de Toledo', '0605', '06'),
('060507', 'Tantarica', '0605', '06'),
('060508', 'Yonan', '0605', '06'),
('060601', 'Cutervo', '0606', '06'),
('060602', 'Callayuc', '0606', '06'),
('060603', 'Choros', '0606', '06'),
('060604', 'Cujillo', '0606', '06'),
('060605', 'La Ramada', '0606', '06'),
('060606', 'Pimpingos', '0606', '06'),
('060607', 'Querocotillo', '0606', '06'),
('060608', 'San Andrés de Cutervo', '0606', '06'),
('060609', 'San Juan de Cutervo', '0606', '06'),
('060610', 'San Luis de Lucma', '0606', '06'),
('060611', 'Santa Cruz', '0606', '06'),
('060612', 'Santo Domingo de la Capilla', '0606', '06'),
('060613', 'Santo Tomas', '0606', '06'),
('060614', 'Socota', '0606', '06'),
('060615', 'Toribio Casanova', '0606', '06'),
('060701', 'Bambamarca', '0607', '06'),
('060702', 'Chugur', '0607', '06'),
('060703', 'Hualgayoc', '0607', '06'),
('060801', 'Jaén', '0608', '06'),
('060802', 'Bellavista', '0608', '06'),
('060803', 'Chontali', '0608', '06'),
('060804', 'Colasay', '0608', '06'),
('060805', 'Huabal', '0608', '06'),
('060806', 'Las Pirias', '0608', '06'),
('060807', 'Pomahuaca', '0608', '06'),
('060808', 'Pucara', '0608', '06'),
('060809', 'Sallique', '0608', '06'),
('060810', 'San Felipe', '0608', '06'),
('060811', 'San José del Alto', '0608', '06'),
('060812', 'Santa Rosa', '0608', '06'),
('060901', 'San Ignacio', '0609', '06'),
('060902', 'Chirinos', '0609', '06'),
('060903', 'Huarango', '0609', '06'),
('060904', 'La Coipa', '0609', '06'),
('060905', 'Namballe', '0609', '06'),
('060906', 'San José de Lourdes', '0609', '06'),
('060907', 'Tabaconas', '0609', '06'),
('061001', 'Pedro Gálvez', '0610', '06'),
('061002', 'Chancay', '0610', '06'),
('061003', 'Eduardo Villanueva', '0610', '06'),
('061004', 'Gregorio Pita', '0610', '06'),
('061005', 'Ichocan', '0610', '06'),
('061006', 'José Manuel Quiroz', '0610', '06'),
('061007', 'José Sabogal', '0610', '06'),
('061101', 'San Miguel', '0611', '06'),
('061102', 'Bolívar', '0611', '06'),
('061103', 'Calquis', '0611', '06'),
('061104', 'Catilluc', '0611', '06'),
('061105', 'El Prado', '0611', '06'),
('061106', 'La Florida', '0611', '06'),
('061107', 'Llapa', '0611', '06'),
('061108', 'Nanchoc', '0611', '06'),
('061109', 'Niepos', '0611', '06'),
('061110', 'San Gregorio', '0611', '06'),
('061111', 'San Silvestre de Cochan', '0611', '06'),
('061112', 'Tongod', '0611', '06'),
('061113', 'Unión Agua Blanca', '0611', '06'),
('061201', 'San Pablo', '0612', '06'),
('061202', 'San Bernardino', '0612', '06'),
('061203', 'San Luis', '0612', '06'),
('061204', 'Tumbaden', '0612', '06'),
('061301', 'Santa Cruz', '0613', '06'),
('061302', 'Andabamba', '0613', '06'),
('061303', 'Catache', '0613', '06'),
('061304', 'Chancaybaños', '0613', '06'),
('061305', 'La Esperanza', '0613', '06'),
('061306', 'Ninabamba', '0613', '06'),
('061307', 'Pulan', '0613', '06'),
('061308', 'Saucepampa', '0613', '06'),
('061309', 'Sexi', '0613', '06'),
('061310', 'Uticyacu', '0613', '06'),
('061311', 'Yauyucan', '0613', '06'),
('070101', 'Callao', '0701', '07'),
('070102', 'Bellavista', '0701', '07'),
('070103', 'Carmen de la Legua Reynoso', '0701', '07'),
('070104', 'La Perla', '0701', '07'),
('070105', 'La Punta', '0701', '07'),
('070106', 'Ventanilla', '0701', '07'),
('070107', 'Mi Perú', '0701', '07'),
('080101', 'Cusco', '0801', '08'),
('080102', 'Ccorca', '0801', '08'),
('080103', 'Poroy', '0801', '08'),
('080104', 'San Jerónimo', '0801', '08'),
('080105', 'San Sebastian', '0801', '08'),
('080106', 'Santiago', '0801', '08'),
('080107', 'Saylla', '0801', '08'),
('080108', 'Wanchaq', '0801', '08'),
('080201', 'Acomayo', '0802', '08'),
('080202', 'Acopia', '0802', '08'),
('080203', 'Acos', '0802', '08'),
('080204', 'Mosoc Llacta', '0802', '08'),
('080205', 'Pomacanchi', '0802', '08'),
('080206', 'Rondocan', '0802', '08'),
('080207', 'Sangarara', '0802', '08'),
('080301', 'Anta', '0803', '08'),
('080302', 'Ancahuasi', '0803', '08'),
('080303', 'Cachimayo', '0803', '08'),
('080304', 'Chinchaypujio', '0803', '08'),
('080305', 'Huarocondo', '0803', '08'),
('080306', 'Limatambo', '0803', '08'),
('080307', 'Mollepata', '0803', '08'),
('080308', 'Pucyura', '0803', '08'),
('080309', 'Zurite', '0803', '08'),
('080401', 'Calca', '0804', '08'),
('080402', 'Coya', '0804', '08'),
('080403', 'Lamay', '0804', '08'),
('080404', 'Lares', '0804', '08'),
('080405', 'Pisac', '0804', '08'),
('080406', 'San Salvador', '0804', '08'),
('080407', 'Taray', '0804', '08'),
('080408', 'Yanatile', '0804', '08'),
('080501', 'Yanaoca', '0805', '08'),
('080502', 'Checca', '0805', '08'),
('080503', 'Kunturkanki', '0805', '08'),
('080504', 'Langui', '0805', '08'),
('080505', 'Layo', '0805', '08'),
('080506', 'Pampamarca', '0805', '08'),
('080507', 'Quehue', '0805', '08'),
('080508', 'Tupac Amaru', '0805', '08'),
('080601', 'Sicuani', '0806', '08'),
('080602', 'Checacupe', '0806', '08'),
('080603', 'Combapata', '0806', '08'),
('080604', 'Marangani', '0806', '08'),
('080605', 'Pitumarca', '0806', '08'),
('080606', 'San Pablo', '0806', '08'),
('080607', 'San Pedro', '0806', '08'),
('080608', 'Tinta', '0806', '08'),
('080701', 'Santo Tomas', '0807', '08'),
('080702', 'Capacmarca', '0807', '08'),
('080703', 'Chamaca', '0807', '08'),
('080704', 'Colquemarca', '0807', '08'),
('080705', 'Livitaca', '0807', '08'),
('080706', 'Llusco', '0807', '08'),
('080707', 'Quiñota', '0807', '08'),
('080708', 'Velille', '0807', '08'),
('080801', 'Espinar', '0808', '08'),
('080802', 'Condoroma', '0808', '08'),
('080803', 'Coporaque', '0808', '08'),
('080804', 'Ocoruro', '0808', '08'),
('080805', 'Pallpata', '0808', '08'),
('080806', 'Pichigua', '0808', '08'),
('080807', 'Suyckutambo', '0808', '08'),
('080808', 'Alto Pichigua', '0808', '08'),
('080901', 'Santa Ana', '0809', '08'),
('080902', 'Echarate', '0809', '08'),
('080903', 'Huayopata', '0809', '08'),
('080904', 'Maranura', '0809', '08'),
('080905', 'Ocobamba', '0809', '08'),
('080906', 'Quellouno', '0809', '08'),
('080907', 'Kimbiri', '0809', '08'),
('080908', 'Santa Teresa', '0809', '08'),
('080909', 'Vilcabamba', '0809', '08'),
('080910', 'Pichari', '0809', '08'),
('080911', 'Inkawasi', '0809', '08'),
('080912', 'Villa Virgen', '0809', '08'),
('080913', 'Villa Kintiarina', '0809', '08'),
('080914', 'Megantoni', '0809', '08'),
('081001', 'Paruro', '0810', '08'),
('081002', 'Accha', '0810', '08'),
('081003', 'Ccapi', '0810', '08'),
('081004', 'Colcha', '0810', '08'),
('081005', 'Huanoquite', '0810', '08'),
('081006', 'Omachaç', '0810', '08'),
('081007', 'Paccaritambo', '0810', '08'),
('081008', 'Pillpinto', '0810', '08'),
('081009', 'Yaurisque', '0810', '08'),
('081101', 'Paucartambo', '0811', '08'),
('081102', 'Caicay', '0811', '08'),
('081103', 'Challabamba', '0811', '08'),
('081104', 'Colquepata', '0811', '08'),
('081105', 'Huancarani', '0811', '08'),
('081106', 'Kosñipata', '0811', '08'),
('081201', 'Urcos', '0812', '08'),
('081202', 'Andahuaylillas', '0812', '08'),
('081203', 'Camanti', '0812', '08'),
('081204', 'Ccarhuayo', '0812', '08'),
('081205', 'Ccatca', '0812', '08'),
('081206', 'Cusipata', '0812', '08'),
('081207', 'Huaro', '0812', '08'),
('081208', 'Lucre', '0812', '08'),
('081209', 'Marcapata', '0812', '08'),
('081210', 'Ocongate', '0812', '08'),
('081211', 'Oropesa', '0812', '08'),
('081212', 'Quiquijana', '0812', '08'),
('081301', 'Urubamba', '0813', '08'),
('081302', 'Chinchero', '0813', '08'),
('081303', 'Huayllabamba', '0813', '08'),
('081304', 'Machupicchu', '0813', '08'),
('081305', 'Maras', '0813', '08'),
('081306', 'Ollantaytambo', '0813', '08'),
('081307', 'Yucay', '0813', '08'),
('090101', 'Huancavelica', '0901', '09'),
('090102', 'Acobambilla', '0901', '09'),
('090103', 'Acoria', '0901', '09'),
('090104', 'Conayca', '0901', '09'),
('090105', 'Cuenca', '0901', '09'),
('090106', 'Huachocolpa', '0901', '09'),
('090107', 'Huayllahuara', '0901', '09'),
('090108', 'Izcuchaca', '0901', '09'),
('090109', 'Laria', '0901', '09'),
('090110', 'Manta', '0901', '09'),
('090111', 'Mariscal Cáceres', '0901', '09'),
('090112', 'Moya', '0901', '09'),
('090113', 'Nuevo Occoro', '0901', '09'),
('090114', 'Palca', '0901', '09'),
('090115', 'Pilchaca', '0901', '09'),
('090116', 'Vilca', '0901', '09'),
('090117', 'Yauli', '0901', '09'),
('090118', 'Ascensión', '0901', '09'),
('090119', 'Huando', '0901', '09'),
('090201', 'Acobamba', '0902', '09'),
('090202', 'Andabamba', '0902', '09'),
('090203', 'Anta', '0902', '09'),
('090204', 'Caja', '0902', '09'),
('090205', 'Marcas', '0902', '09'),
('090206', 'Paucara', '0902', '09'),
('090207', 'Pomacocha', '0902', '09'),
('090208', 'Rosario', '0902', '09'),
('090301', 'Lircay', '0903', '09'),
('090302', 'Anchonga', '0903', '09'),
('090303', 'Callanmarca', '0903', '09'),
('090304', 'Ccochaccasa', '0903', '09'),
('090305', 'Chincho', '0903', '09'),
('090306', 'Congalla', '0903', '09'),
('090307', 'Huanca-Huanca', '0903', '09'),
('090308', 'Huayllay Grande', '0903', '09'),
('090309', 'Julcamarca', '0903', '09'),
('090310', 'San Antonio de Antaparco', '0903', '09'),
('090311', 'Santo Tomas de Pata', '0903', '09'),
('090312', 'Secclla', '0903', '09'),
('090401', 'Castrovirreyna', '0904', '09'),
('090402', 'Arma', '0904', '09'),
('090403', 'Aurahua', '0904', '09'),
('090404', 'Capillas', '0904', '09'),
('090405', 'Chupamarca', '0904', '09'),
('090406', 'Cocas', '0904', '09'),
('090407', 'Huachos', '0904', '09'),
('090408', 'Huamatambo', '0904', '09'),
('090409', 'Mollepampa', '0904', '09'),
('090410', 'San Juan', '0904', '09'),
('090411', 'Santa Ana', '0904', '09'),
('090412', 'Tantara', '0904', '09'),
('090413', 'Ticrapo', '0904', '09'),
('090501', 'Churcampa', '0905', '09'),
('090502', 'Anco', '0905', '09'),
('090503', 'Chinchihuasi', '0905', '09'),
('090504', 'El Carmen', '0905', '09'),
('090505', 'La Merced', '0905', '09'),
('090506', 'Locroja', '0905', '09'),
('090507', 'Paucarbamba', '0905', '09'),
('090508', 'San Miguel de Mayocc', '0905', '09'),
('090509', 'San Pedro de Coris', '0905', '09'),
('090510', 'Pachamarca', '0905', '09'),
('090511', 'Cosme', '0905', '09'),
('090601', 'Huaytara', '0906', '09'),
('090602', 'Ayavi', '0906', '09'),
('090603', 'Córdova', '0906', '09'),
('090604', 'Huayacundo Arma', '0906', '09'),
('090605', 'Laramarca', '0906', '09'),
('090606', 'Ocoyo', '0906', '09'),
('090607', 'Pilpichaca', '0906', '09'),
('090608', 'Querco', '0906', '09'),
('090609', 'Quito-Arma', '0906', '09'),
('090610', 'San Antonio de Cusicancha', '0906', '09'),
('090611', 'San Francisco de Sangayaico', '0906', '09'),
('090612', 'San Isidro', '0906', '09'),
('090613', 'Santiago de Chocorvos', '0906', '09'),
('090614', 'Santiago de Quirahuara', '0906', '09'),
('090615', 'Santo Domingo de Capillas', '0906', '09'),
('090616', 'Tambo', '0906', '09'),
('090701', 'Pampas', '0907', '09'),
('090702', 'Acostambo', '0907', '09'),
('090703', 'Acraquia', '0907', '09'),
('090704', 'Ahuaycha', '0907', '09'),
('090705', 'Colcabamba', '0907', '09'),
('090706', 'Daniel Hernández', '0907', '09'),
('090707', 'Huachocolpa', '0907', '09'),
('090709', 'Huaribamba', '0907', '09'),
('090710', 'Ñahuimpuquio', '0907', '09'),
('090711', 'Pazos', '0907', '09'),
('090713', 'Quishuar', '0907', '09'),
('090714', 'Salcabamba', '0907', '09'),
('090715', 'Salcahuasi', '0907', '09'),
('090716', 'San Marcos de Rocchac', '0907', '09'),
('090717', 'Surcubamba', '0907', '09'),
('090718', 'Tintay Puncu', '0907', '09'),
('090719', 'Quichuas', '0907', '09'),
('090720', 'Andaymarca', '0907', '09'),
('090721', 'Roble', '0907', '09'),
('090722', 'Pichos', '0907', '09'),
('090723', 'Santiago de Tucuma', '0907', '09'),
('100101', 'Huanuco', '1001', '10'),
('100102', 'Amarilis', '1001', '10'),
('100103', 'Chinchao', '1001', '10'),
('100104', 'Churubamba', '1001', '10'),
('100105', 'Margos', '1001', '10'),
('100106', 'Quisqui (Kichki)', '1001', '10'),
('100107', 'San Francisco de Cayran', '1001', '10'),
('100108', 'San Pedro de Chaulan', '1001', '10'),
('100109', 'Santa María del Valle', '1001', '10'),
('100110', 'Yarumayo', '1001', '10'),
('100111', 'Pillco Marca', '1001', '10'),
('100112', 'Yacus', '1001', '10'),
('100113', 'San Pablo de Pillao', '1001', '10'),
('100201', 'Ambo', '1002', '10'),
('100202', 'Cayna', '1002', '10'),
('100203', 'Colpas', '1002', '10'),
('100204', 'Conchamarca', '1002', '10'),
('100205', 'Huacar', '1002', '10'),
('100206', 'San Francisco', '1002', '10'),
('100207', 'San Rafael', '1002', '10'),
('100208', 'Tomay Kichwa', '1002', '10'),
('100301', 'La Unión', '1003', '10'),
('100307', 'Chuquis', '1003', '10'),
('100311', 'Marías', '1003', '10'),
('100313', 'Pachas', '1003', '10'),
('100316', 'Quivilla', '1003', '10'),
('100317', 'Ripan', '1003', '10'),
('100321', 'Shunqui', '1003', '10'),
('100322', 'Sillapata', '1003', '10'),
('100323', 'Yanas', '1003', '10'),
('100401', 'Huacaybamba', '1004', '10'),
('100402', 'Canchabamba', '1004', '10'),
('100403', 'Cochabamba', '1004', '10'),
('100404', 'Pinra', '1004', '10'),
('100501', 'Llata', '1005', '10'),
('100502', 'Arancay', '1005', '10'),
('100503', 'Chavín de Pariarca', '1005', '10'),
('100504', 'Jacas Grande', '1005', '10'),
('100505', 'Jircan', '1005', '10'),
('100506', 'Miraflores', '1005', '10'),
('100507', 'Monzón', '1005', '10'),
('100508', 'Punchao', '1005', '10'),
('100509', 'Puños', '1005', '10'),
('100510', 'Singa', '1005', '10'),
('100511', 'Tantamayo', '1005', '10'),
('100601', 'Rupa-Rupa', '1006', '10'),
('100602', 'Daniel Alomía Robles', '1006', '10'),
('100603', 'Hermílio Valdizan', '1006', '10'),
('100604', 'José Crespo y Castillo', '1006', '10'),
('100605', 'Luyando', '1006', '10'),
('100606', 'Mariano Damaso Beraun', '1006', '10'),
('100607', 'Pucayacu', '1006', '10'),
('100608', 'Castillo Grande', '1006', '10'),
('100609', 'Pueblo Nuevo', '1006', '10'),
('100610', 'Santo Domingo de Anda', '1006', '10'),
('100701', 'Huacrachuco', '1007', '10'),
('100702', 'Cholon', '1007', '10'),
('100703', 'San Buenaventura', '1007', '10'),
('100704', 'La Morada', '1007', '10'),
('100705', 'Santa Rosa de Alto Yanajanca', '1007', '10'),
('100801', 'Panao', '1008', '10'),
('100802', 'Chaglla', '1008', '10'),
('100803', 'Molino', '1008', '10'),
('100804', 'Umari', '1008', '10'),
('100901', 'Puerto Inca', '1009', '10'),
('100902', 'Codo del Pozuzo', '1009', '10'),
('100903', 'Honoria', '1009', '10'),
('100904', 'Tournavista', '1009', '10'),
('100905', 'Yuyapichis', '1009', '10'),
('101001', 'Jesús', '1010', '10'),
('101002', 'Baños', '1010', '10'),
('101003', 'Jivia', '1010', '10'),
('101004', 'Queropalca', '1010', '10'),
('101005', 'Rondos', '1010', '10'),
('101006', 'San Francisco de Asís', '1010', '10'),
('101007', 'San Miguel de Cauri', '1010', '10'),
('101101', 'Chavinillo', '1011', '10'),
('101102', 'Cahuac', '1011', '10'),
('101103', 'Chacabamba', '1011', '10'),
('101104', 'Aparicio Pomares', '1011', '10'),
('101105', 'Jacas Chico', '1011', '10'),
('101106', 'Obas', '1011', '10'),
('101107', 'Pampamarca', '1011', '10'),
('101108', 'Choras', '1011', '10'),
('110101', 'Ica', '1101', '11'),
('110102', 'La Tinguiña', '1101', '11'),
('110103', 'Los Aquijes', '1101', '11'),
('110104', 'Ocucaje', '1101', '11'),
('110105', 'Pachacutec', '1101', '11'),
('110106', 'Parcona', '1101', '11'),
('110107', 'Pueblo Nuevo', '1101', '11'),
('110108', 'Salas', '1101', '11')

INSERT INTO DISTRITO (IdDistrito, Descripcion, IdProvincia, IdDepartamento) VALUES
('110109', 'San José de Los Molinos', '1101', '11'),
('110110', 'San Juan Bautista', '1101', '11'),
('110111', 'Santiago', '1101', '11'),
('110112', 'Subtanjalla', '1101', '11'),
('110113', 'Tate', '1101', '11'),
('110114', 'Yauca del Rosario', '1101', '11'),
('110201', 'Chincha Alta', '1102', '11'),
('110202', 'Alto Laran', '1102', '11'),
('110203', 'Chavin', '1102', '11'),
('110204', 'Chincha Baja', '1102', '11'),
('110205', 'El Carmen', '1102', '11'),
('110206', 'Grocio Prado', '1102', '11'),
('110207', 'Pueblo Nuevo', '1102', '11'),
('110208', 'San Juan de Yanac', '1102', '11'),
('110209', 'San Pedro de Huacarpana', '1102', '11'),
('110210', 'Sunampe', '1102', '11'),
('110211', 'Tambo de Mora', '1102', '11'),
('110301', 'Nasca', '1103', '11'),
('110302', 'Changuillo', '1103', '11'),
('110303', 'El Ingenio', '1103', '11'),
('110304', 'Marcona', '1103', '11'),
('110305', 'Vista Alegre', '1103', '11'),
('110401', 'Palpa', '1104', '11'),
('110402', 'Llipata', '1104', '11'),
('110403', 'Río Grande', '1104', '11'),
('110404', 'Santa Cruz', '1104', '11'),
('110405', 'Tibillo', '1104', '11'),
('110501', 'Pisco', '1105', '11'),
('110502', 'Huancano', '1105', '11'),
('110503', 'Humay', '1105', '11'),
('110504', 'Independencia', '1105', '11'),
('110505', 'Paracas', '1105', '11'),
('110506', 'San Andrés', '1105', '11'),
('110507', 'San Clemente', '1105', '11'),
('110508', 'Tupac Amaru Inca', '1105', '11'),
('120101', 'Huancayo', '1201', '12'),
('120104', 'Carhuacallanga', '1201', '12'),
('120105', 'Chacapampa', '1201', '12'),
('120106', 'Chicche', '1201', '12'),
('120107', 'Chilca', '1201', '12'),
('120108', 'Chongos Alto', '1201', '12'),
('120111', 'Chupuro', '1201', '12'),
('120112', 'Colca', '1201', '12'),
('120113', 'Cullhuas', '1201', '12'),
('120114', 'El Tambo', '1201', '12'),
('120116', 'Huacrapuquio', '1201', '12'),
('120117', 'Hualhuas', '1201', '12'),
('120119', 'Huancan', '1201', '12'),
('120120', 'Huasicancha', '1201', '12'),
('120121', 'Huayucachi', '1201', '12'),
('120122', 'Ingenio', '1201', '12'),
('120124', 'Pariahuanca', '1201', '12'),
('120125', 'Pilcomayo', '1201', '12'),
('120126', 'Pucara', '1201', '12'),
('120127', 'Quichuay', '1201', '12'),
('120128', 'Quilcas', '1201', '12'),
('120129', 'San Agustín', '1201', '12'),
('120130', 'San Jerónimo de Tunan', '1201', '12'),
('120132', 'Saño', '1201', '12'),
('120133', 'Sapallanga', '1201', '12'),
('120134', 'Sicaya', '1201', '12'),
('120135', 'Santo Domingo de Acobamba', '1201', '12'),
('120136', 'Viques', '1201', '12'),
('120201', 'Concepción', '1202', '12'),
('120202', 'Aco', '1202', '12'),
('120203', 'Andamarca', '1202', '12'),
('120204', 'Chambara', '1202', '12'),
('120205', 'Cochas', '1202', '12'),
('120206', 'Comas', '1202', '12'),
('120207', 'Heroínas Toledo', '1202', '12'),
('120208', 'Manzanares', '1202', '12'),
('120209', 'Mariscal Castilla', '1202', '12'),
('120210', 'Matahuasi', '1202', '12'),
('120211', 'Mito', '1202', '12'),
('120212', 'Nueve de Julio', '1202', '12'),
('120213', 'Orcotuna', '1202', '12'),
('120214', 'San José de Quero', '1202', '12'),
('120215', 'Santa Rosa de Ocopa', '1202', '12'),
('120301', 'Chanchamayo', '1203', '12'),
('120302', 'Perene', '1203', '12'),
('120303', 'Pichanaqui', '1203', '12'),
('120304', 'San Luis de Shuaro', '1203', '12'),
('120305', 'San Ramón', '1203', '12'),
('120306', 'Vitoc', '1203', '12'),
('120401', 'Jauja', '1204', '12'),
('120402', 'Acolla', '1204', '12'),
('120403', 'Apata', '1204', '12'),
('120404', 'Ataura', '1204', '12'),
('120405', 'Canchayllo', '1204', '12'),
('120406', 'Curicaca', '1204', '12'),
('120407', 'El Mantaro', '1204', '12'),
('120408', 'Huamali', '1204', '12'),
('120409', 'Huaripampa', '1204', '12'),
('120410', 'Huertas', '1204', '12'),
('120411', 'Janjaillo', '1204', '12'),
('120412', 'Julcán', '1204', '12'),
('120413', 'Leonor Ordóñez', '1204', '12'),
('120414', 'Llocllapampa', '1204', '12'),
('120415', 'Marco', '1204', '12'),
('120416', 'Masma', '1204', '12'),
('120417', 'Masma Chicche', '1204', '12'),
('120418', 'Molinos', '1204', '12'),
('120419', 'Monobamba', '1204', '12'),
('120420', 'Muqui', '1204', '12'),
('120421', 'Muquiyauyo', '1204', '12'),
('120422', 'Paca', '1204', '12'),
('120423', 'Paccha', '1204', '12'),
('120424', 'Pancan', '1204', '12'),
('120425', 'Parco', '1204', '12'),
('120426', 'Pomacancha', '1204', '12'),
('120427', 'Ricran', '1204', '12'),
('120428', 'San Lorenzo', '1204', '12'),
('120429', 'San Pedro de Chunan', '1204', '12'),
('120430', 'Sausa', '1204', '12'),
('120431', 'Sincos', '1204', '12'),
('120432', 'Tunan Marca', '1204', '12'),
('120433', 'Yauli', '1204', '12'),
('120434', 'Yauyos', '1204', '12'),
('120501', 'Junin', '1205', '12'),
('120502', 'Carhuamayo', '1205', '12'),
('120503', 'Ondores', '1205', '12'),
('120504', 'Ulcumayo', '1205', '12'),
('120601', 'Satipo', '1206', '12'),
('120602', 'Coviriali', '1206', '12'),
('120603', 'Llaylla', '1206', '12'),
('120604', 'Mazamari', '1206', '12'),
('120605', 'Pampa Hermosa', '1206', '12'),
('120606', 'Pangoa', '1206', '12'),
('120607', 'Río Negro', '1206', '12'),
('120608', 'Río Tambo', '1206', '12'),
('120609', 'Vizcatan del Ene', '1206', '12'),
('120701', 'Tarma', '1207', '12'),
('120702', 'Acobamba', '1207', '12'),
('120703', 'Huaricolca', '1207', '12'),
('120704', 'Huasahuasi', '1207', '12'),
('120705', 'La Unión', '1207', '12'),
('120706', 'Palca', '1207', '12'),
('120707', 'Palcamayo', '1207', '12'),
('120708', 'San Pedro de Cajas', '1207', '12'),
('120709', 'Tapo', '1207', '12'),
('120801', 'La Oroya', '1208', '12'),
('120802', 'Chacapalpa', '1208', '12'),
('120803', 'Huay-Huay', '1208', '12'),
('120804', 'Marcapomacocha', '1208', '12'),
('120805', 'Morococha', '1208', '12'),
('120806', 'Paccha', '1208', '12'),
('120807', 'Santa Bárbara de Carhuacayan', '1208', '12'),
('120808', 'Santa Rosa de Sacco', '1208', '12'),
('120809', 'Suitucancha', '1208', '12'),
('120810', 'Yauli', '1208', '12'),
('120901', 'Chupaca', '1209', '12'),
('120902', 'Ahuac', '1209', '12'),
('120903', 'Chongos Bajo', '1209', '12'),
('120904', 'Huachac', '1209', '12'),
('120905', 'Huamancaca Chico', '1209', '12'),
('120906', 'San Juan de Iscos', '1209', '12'),
('120907', 'San Juan de Jarpa', '1209', '12'),
('120908', 'Tres de Diciembre', '1209', '12'),
('120909', 'Yanacancha', '1209', '12'),
('130101', 'Trujillo', '1301', '13'),
('130102', 'El Porvenir', '1301', '13'),
('130103', 'Florencia de Mora', '1301', '13'),
('130104', 'Huanchaco', '1301', '13'),
('130105', 'La Esperanza', '1301', '13'),
('130106', 'Laredo', '1301', '13'),
('130107', 'Moche', '1301', '13'),
('130108', 'Poroto', '1301', '13'),
('130109', 'Salaverry', '1301', '13'),
('130110', 'Simbal', '1301', '13'),
('130111', 'Victor Larco Herrera', '1301', '13'),
('130201', 'Ascope', '1302', '13'),
('130202', 'Chicama', '1302', '13'),
('130203', 'Chocope', '1302', '13'),
('130204', 'Magdalena de Cao', '1302', '13'),
('130205', 'Paijan', '1302', '13'),
('130206', 'Rázuri', '1302', '13'),
('130207', 'Santiago de Cao', '1302', '13'),
('130208', 'Casa Grande', '1302', '13'),
('130301', 'Bolívar', '1303', '13'),
('130302', 'Bambamarca', '1303', '13'),
('130303', 'Condormarca', '1303', '13'),
('130304', 'Longotea', '1303', '13'),
('130305', 'Uchumarca', '1303', '13'),
('130306', 'Ucuncha', '1303', '13'),
('130401', 'Chepen', '1304', '13'),
('130402', 'Pacanga', '1304', '13'),
('130403', 'Pueblo Nuevo', '1304', '13'),
('130501', 'Julcan', '1305', '13'),
('130502', 'Calamarca', '1305', '13'),
('130503', 'Carabamba', '1305', '13'),
('130504', 'Huaso', '1305', '13'),
('130601', 'Otuzco', '1306', '13'),
('130602', 'Agallpampa', '1306', '13'),
('130604', 'Charat', '1306', '13'),
('130605', 'Huaranchal', '1306', '13'),
('130606', 'La Cuesta', '1306', '13'),
('130608', 'Mache', '1306', '13'),
('130610', 'Paranday', '1306', '13'),
('130611', 'Salpo', '1306', '13'),
('130613', 'Sinsicap', '1306', '13'),
('130614', 'Usquil', '1306', '13'),
('130701', 'San Pedro de Lloc', '1307', '13'),
('130702', 'Guadalupe', '1307', '13'),
('130703', 'Jequetepeque', '1307', '13'),
('130704', 'Pacasmayo', '1307', '13'),
('130705', 'San José', '1307', '13'),
('130801', 'Tayabamba', '1308', '13'),
('130802', 'Buldibuyo', '1308', '13'),
('130803', 'Chillia', '1308', '13'),
('130804', 'Huancaspata', '1308', '13'),
('130805', 'Huaylillas', '1308', '13'),
('130806', 'Huayo', '1308', '13'),
('130807', 'Ongon', '1308', '13'),
('130808', 'Parcoy', '1308', '13'),
('130809', 'Pataz', '1308', '13'),
('130810', 'Pias', '1308', '13'),
('130811', 'Santiago de Challas', '1308', '13'),
('130812', 'Taurija', '1308', '13'),
('130813', 'Urpay', '1308', '13'),
('130901', 'Huamachuco', '1309', '13'),
('130902', 'Chugay', '1309', '13'),
('130903', 'Cochorco', '1309', '13'),
('130904', 'Curgos', '1309', '13'),
('130905', 'Marcabal', '1309', '13'),
('130906', 'Sanagoran', '1309', '13'),
('130907', 'Sarin', '1309', '13'),
('130908', 'Sartimbamba', '1309', '13'),
('131001', 'Santiago de Chuco', '1310', '13'),
('131002', 'Angasmarca', '1310', '13'),
('131003', 'Cachicadan', '1310', '13'),
('131004', 'Mollebamba', '1310', '13'),
('131005', 'Mollepata', '1310', '13'),
('131006', 'Quiruvilca', '1310', '13'),
('131007', 'Santa Cruz de Chuca', '1310', '13'),
('131008', 'Sitabamba', '1310', '13'),
('131101', 'Cascas', '1311', '13'),
('131102', 'Lucma', '1311', '13'),
('131103', 'Marmot', '1311', '13'),
('131104', 'Sayapullo', '1311', '13'),
('131201', 'Viru', '1312', '13'),
('131202', 'Chao', '1312', '13'),
('131203', 'Guadalupito', '1312', '13'),
('140101', 'Chiclayo', '1401', '14'),
('140102', 'Chongoyape', '1401', '14'),
('140103', 'Eten', '1401', '14'),
('140104', 'Eten Puerto', '1401', '14'),
('140105', 'José Leonardo Ortiz', '1401', '14'),
('140106', 'La Victoria', '1401', '14'),
('140107', 'Lagunas', '1401', '14'),
('140108', 'Monsefu', '1401', '14'),
('140109', 'Nueva Arica', '1401', '14'),
('140110', 'Oyotun', '1401', '14'),
('140111', 'Picsi', '1401', '14'),
('140112', 'Pimentel', '1401', '14'),
('140113', 'Reque', '1401', '14'),
('140114', 'Santa Rosa', '1401', '14'),
('140115', 'Saña', '1401', '14'),
('140116', 'Cayalti', '1401', '14'),
('140117', 'Patapo', '1401', '14'),
('140118', 'Pomalca', '1401', '14'),
('140119', 'Pucala', '1401', '14'),
('140120', 'Tuman', '1401', '14'),
('140201', 'Ferreñafe', '1402', '14'),
('140202', 'Cañaris', '1402', '14'),
('140203', 'Incahuasi', '1402', '14'),
('140204', 'Manuel Antonio Mesones Muro', '1402', '14'),
('140205', 'Pitipo', '1402', '14'),
('140206', 'Pueblo Nuevo', '1402', '14'),
('140301', 'Lambayeque', '1403', '14'),
('140302', 'Chochope', '1403', '14'),
('140303', 'Illimo', '1403', '14'),
('140304', 'Jayanca', '1403', '14'),
('140305', 'Mochumi', '1403', '14'),
('140306', 'Morrope', '1403', '14'),
('140307', 'Motupe', '1403', '14'),
('140308', 'Olmos', '1403', '14'),
('140309', 'Pacora', '1403', '14'),
('140310', 'Salas', '1403', '14'),
('140311', 'San José', '1403', '14'),
('140312', 'Tucume', '1403', '14'),
('150101', 'Lima', '1501', '15'),
('150102', 'Ancón', '1501', '15'),
('150103', 'Ate', '1501', '15'),
('150104', 'Barranco', '1501', '15'),
('150105', 'Breña', '1501', '15'),
('150106', 'Carabayllo', '1501', '15'),
('150107', 'Chaclacayo', '1501', '15'),
('150108', 'Chorrillos', '1501', '15'),
('150109', 'Cieneguilla', '1501', '15'),
('150110', 'Comas', '1501', '15'),
('150111', 'El Agustino', '1501', '15'),
('150112', 'Independencia', '1501', '15'),
('150113', 'Jesús María', '1501', '15'),
('150114', 'La Molina', '1501', '15'),
('150115', 'La Victoria', '1501', '15'),
('150116', 'Lince', '1501', '15'),
('150117', 'Los Olivos', '1501', '15'),
('150118', 'Lurigancho', '1501', '15'),
('150119', 'Lurin', '1501', '15'),
('150120', 'Magdalena del Mar', '1501', '15'),
('150121', 'Pueblo Libre', '1501', '15'),
('150122', 'Miraflores', '1501', '15'),
('150123', 'Pachacamac', '1501', '15'),
('150124', 'Pucusana', '1501', '15'),
('150125', 'Puente Piedra', '1501', '15'),
('150126', 'Punta Hermosa', '1501', '15'),
('150127', 'Punta Negra', '1501', '15'),
('150128', 'Rímac', '1501', '15'),
('150129', 'San Bartolo', '1501', '15'),
('150130', 'San Borja', '1501', '15'),
('150131', 'San Isidro', '1501', '15'),
('150132', 'San Juan de Lurigancho', '1501', '15'),
('150133', 'San Juan de Miraflores', '1501', '15'),
('150134', 'San Luis', '1501', '15'),
('150135', 'San Martín de Porres', '1501', '15'),
('150136', 'San Miguel', '1501', '15'),
('150137', 'Santa Anita', '1501', '15'),
('150138', 'Santa María del Mar', '1501', '15'),
('150139', 'Santa Rosa', '1501', '15'),
('150140', 'Santiago de Surco', '1501', '15'),
('150141', 'Surquillo', '1501', '15'),
('150142', 'Villa El Salvador', '1501', '15'),
('150143', 'Villa María del Triunfo', '1501', '15'),
('150201', 'Barranca', '1502', '15'),
('150202', 'Paramonga', '1502', '15'),
('150203', 'Pativilca', '1502', '15'),
('150204', 'Supe', '1502', '15'),
('150205', 'Supe Puerto', '1502', '15'),
('150301', 'Cajatambo', '1503', '15'),
('150302', 'Copa', '1503', '15'),
('150303', 'Gorgor', '1503', '15'),
('150304', 'Huancapon', '1503', '15'),
('150305', 'Manas', '1503', '15'),
('150401', 'Canta', '1504', '15'),
('150402', 'Arahuay', '1504', '15'),
('150403', 'Huamantanga', '1504', '15'),
('150404', 'Huaros', '1504', '15'),
('150405', 'Lachaqui', '1504', '15'),
('150406', 'San Buenaventura', '1504', '15'),
('150407', 'Santa Rosa de Quives', '1504', '15')

select * from [dbo].[PRODUCTO]
