/************************************************************** NIVELL 1 ********************************************************************************/

-- 1.1.- La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials sobre les targetes de crèdit.
-- La nova taula ha de ser capaç d'identificar de manera única cada targeta i establir una relació adequada amb les altres dues taules ("transaction" i "company").
-- Després de crear la taula serà necessari que ingressis la informació del document denominat "dades_introduir_credit".
-- Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.

create table credit_card (
	id varchar (255) not null,                           -- NOT NULL ya que una PK no puede adquirir este valor
    iban varchar (255) null,
    pan varchar (255) null,
    pin int null,
    cvv int null,
    expiring_date varchar (10) null,
    primary key (id));                                   -- Tipo varchar por el formato de la fecha no estandard mm/dd/aaaa


ALTER TABLE transaction                                  -- Genero nueva FK en la tabla transaction para poder relacionar
ADD CONSTRAINT FK_transaction_credit_card 
FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);


-- 1.2.- El departament de Recursos Humans ha identificat un error en el número de compte de l'usuari amb ID CcU-2938.
--  La informació que ha de mostrar-se per a aquest registre és: R323456312213576817699999. Recorda mostrar que el canvi es va realitzar.

update credit_card                        -- Modificación del IBAN asociado
set iban='R323456312213576817699999'
where id='CcU-2938';

select id,iban,
case                                      -- Añadir mensaje modificación
    when id!='CcU-2938' then 'No'
    else 'IBAN actualizado'
end as 'ACTUALIZACION IBAN'
from credit_card;


-- 1.3.- En la taula "transaction" ingressa un nou usuari amb la següent informació:
		/*    Id	108B1D1D-5B23-A76C-55EF-C568E49A99DD
		      credit_card_id	CcU-9999
		      company_id	b-9999
		      user_id	9999
		      lat	829.999
		      longitude	-117.999
		      amount	111.11 
		      declined	0                                                       */

-- Paso 1:
insert into company(id)      -- Asegurar PK vs. FK entre las tablas company y transaction, para evitar problemas con los CONSTRAIT
values ('b-9999');

insert into credit_card(id)  -- Asegurar PK vs. FK entre las tablas credit_card y transaction, para evitar problemas con los CONSTRAIT
values ('CcU-9999');

-- Paso 2:
insert into transaction (id,credit_card_id,company_id,user_id,lat,longitude,amount,declined)         -- Inserto los valores en la tabla
values ('108B1D1D-5B23-A76C-55EF-C568E49A99DD','CcU-9999','b-9999',9999,829.999,-117.999,111.11,0);  -- referenciada

-- Paso 3:
select *                                            -- Mostrar que los datos se han introducido correctamente
from transaction
where company_id='b-9999';


-- 1.4.- Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card. Recorda mostrar el canvi realitzat

alter table credit_card drop column pan;

show columns from credit_card;


/************************************************************** NIVELL 2 ********************************************************************************/

-- 2.1.- Elimina de la taula transaction el registre amb ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de la base de dades.
 
delete from transaction where id='02C6201E-D90A-1859-B4EE-88D2986D3B02';

select *
from transaction
where id='02C6201E-D90A-1859-B4EE-88D2986D3B02';


-- 2.2.- La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives.
-- S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions.
-- Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació:
-- 		Nom de la companyia.
-- 		Telèfon de contacte.
-- 		País de residència.
-- 		Mitjana de compra realitzat per cada companyia.
-- 		Presenta la vista creada, ordenant les dades de major a menor mitjana de compra.

create view VistaMarketing as
select company_name,phone,country,round(avg(amount),2) as 'MEDIA DE COMPRAS'  -- Query que devuelve los datos solicitados
from company
join transaction on company.id=transaction.company_id
group by company_name,phone,country
order by round(avg(amount),2) desc;


-- 2.3.- Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany"
select *
from VistaMarketing
where country='Germany';


/************************************************************** NIVELL 3 ********************************************************************************/

-- 3.1.- La setmana vinent tindràs una nova reunió amb els gerents de màrqueting.
-- Un company del teu equip va realitzar modificacions en la base de dades, però no recorda com les va realitzar.
-- Et demana que l'ajudis a deixar els comandos executats per a obtenir el següent diagrama:

-- Cambio de tipo de relación entre las tablas credit_card y transaction
ALTER TABLE user                           -- Borrar la constraint de data_user
DROP FOREIGN KEY user_ibfk_1;

insert into user (id)                      -- Añadir el nuevo usuario (9999) del ejercicio 1.3 (de lo contrario no se cumple la restricción)
values (9999);

ALTER TABLE transaction                    -- Crear una nueva FK en transaction
ADD CONSTRAINT FK_transaction_user_id
FOREIGN KEY (user_id) REFERENCES user(id);


-- Cambios tabla company
-- Eliminar el campo website
alter table company drop column website;  -- Instrucción para eliminar el campo
describe company;                         -- Comprobación de que el campo ha sido eliminado


-- Cambios tabla credit_card
-- Cambiar el parámetro de tamaño para las VARCHAR de los campos id(255->20)
ALTER TABLE transaction                                   -- 'Rompo' la relación entre tablas, ya que el campo es FK de otra tabla
DROP CONSTRAINT FK_transaction_credit_card ;

alter table credit_card modify column id varchar(20);     -- Modifico el tipo del campo

ALTER TABLE transaction                                   -- Genero de nuevo la FK en la tabla transaction para poder relacionar
ADD CONSTRAINT FK_transaction_credit_card 
FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);

-- Cambiar el parámetro de tamaño para las VARCHAR de los campos iban(255->50) y expiring_date(10->20)
alter table credit_card modify column iban varchar(50);
alter table credit_card modify column expiring_date varchar(20);

-- Cambiar el tipo al campo pin(INT->VARCHAR(4))
alter table credit_card modify column pin varchar(4);

-- Añadir un nuevo campo fecha_actual(DATE)
alter table credit_card add fecha_actual date null;

-- Compruebo los cambios realizados
describe credit_card;


-- Cambios tabla user
-- Cambiar el nombre de la tabla user->data_user
alter table user
rename to data_user;

-- Cambiar el nombre del campo email->personal_email
alter table data_user
rename column email to personal_email;

-- Comprobación de los cambios realizados
describe data_user;


-- 3.2.- L'empresa també et sol·licita crear una vista anomenada "InformeTecnico" que contingui la següent informació:
--      ID de la transacció
--      Nom de l'usuari/ària
--   	Cognom de l'usuari/ària
--      IBAN de la targeta de crèdit usada.
--      Nom de la companyia de la transacció realitzada.
-- Assegura't d'incloure informació rellevant de totes dues taules i utilitza àlies per a canviar de nom columnes segons sigui necessari.
-- Mostra els resultats de la vista, ordena els resultats de manera descendent en funció de la variable ID de transaction.

create view InformeTecnico as
select transaction.id as idTransaction,data_user.name as userName,data_user.surname as userSurname,credit_card.iban as ibanCreditCard,company.company_name as companyName,transaction.amount as importe,transaction.declined
from transaction
join data_user on transaction.user_id=data_user.id
join credit_card on transaction.credit_card_id=credit_card.id
join company on transaction.company_id=company.id
order by transaction.id DESC;

