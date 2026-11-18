extends Node
class_name NovaOwnerAccessService

signal owner_session_changed(is_owner: bool)

# El acceso de propietario queda cerrado hasta que NOVA tenga una identidad
# propia y una sesión firmada verificable compartida con Fútbol Nova.
# No se aceptan credenciales ni tokens de proveedores externos.
const OWNER_USER_ID := "e2b76b60-09b4-4e01-a93f-00c9bd7e257e"
const AUTH_STATE := "waiting_for_nova_native_identity"

func is_owner_authenticated() -> bool:
	return false

func sign_in_owner(_email: String = "", _password: String = "") -> Dictionary:
	clear_owner_session()
	return {
		"ok": false,
		"code": "NOVA_IDENTITY_NOT_INTEGRATED",
		"error": "El acceso de propietario estará disponible cuando la identidad nativa de NOVA esté integrada y verificada. No se utiliza autenticación externa."
	}

func verify_owner_session() -> bool:
	clear_owner_session()
	return false

func clear_owner_session() -> void:
	owner_session_changed.emit(false)
