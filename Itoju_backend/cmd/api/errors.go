package api

import (
	"fmt"
	"net/http"
	"sort"
)

func (app *Application) logError(r *http.Request, err error) {
	app.Logger.PrintError(err, map[string]string{
		"request_method": r.Method,
		"request_url":    r.URL.String()})
}

func (app *Application) errorResponse(w http.ResponseWriter, r *http.Request, status int, message any) {
	env := envelope{"error": message}
	err := app.writeJSON(w, status, env, nil)
	if err != nil {
		app.logError(r, err)
		w.WriteHeader(http.StatusInternalServerError)
	}
}

func (app *Application) serverErrorResponse(w http.ResponseWriter, r *http.Request, err error) {
	app.logError(r, err)
	message := "the server encountered a problem and could not process your request"
	env := envelope{
		"error": message,
	}
	// Only expose raw internal error details in non-production environments;
	// in prod they leak DB/driver internals (table/column/constraint names).
	if app.Config.Env != "production" {
		env["devError"] = err.Error()
	}
	err = app.writeJSON(w, http.StatusInternalServerError, env, nil)
	if err != nil {
		app.logError(r, err)
		w.WriteHeader(http.StatusInternalServerError)
	}
}

func (app *Application) NotFoundResponse(w http.ResponseWriter, r *http.Request) {
	message := "the requested resource could not be found"
	app.errorResponse(w, r, http.StatusNotFound, message)
}
func (app *Application) MethodNotAllowedResponse(w http.ResponseWriter, r *http.Request) {
	message := fmt.Sprintf("the %s method is not supported for this resource", r.Method)
	app.errorResponse(w, r, http.StatusMethodNotAllowed, message)
}
func (app *Application) badRequestResponse(w http.ResponseWriter, r *http.Request, err error) {
	app.errorResponse(w, r, http.StatusBadRequest, err.Error())
}

// failedValidationResponse reports ONE validation failure (the client shows a
// single message). Field names are sorted so the same bad input always yields the
// same message — Go randomises map iteration, which used to make it flap.
func (app *Application) failedValidationResponse(w http.ResponseWriter, r *http.Request, errors map[string]string) {
	var errorMsg string
	if len(errors) > 0 {
		keys := make([]string, 0, len(errors))
		for k := range errors {
			keys = append(keys, k)
		}
		sort.Strings(keys)
		errorMsg = keys[0] + " " + errors[keys[0]]
	}
	app.errorResponse(w, r, http.StatusUnprocessableEntity, errorMsg)
}
func (app *Application) editConflictResponse(w http.ResponseWriter, r *http.Request) {
	message := "unable to update the record due to an edit conflict, please try again"
	app.errorResponse(w, r, http.StatusConflict, message)
}
func (app *Application) recordAlreadyExistsResponse(w http.ResponseWriter, r *http.Request) {
	message := "could't create, record already exists"
	app.errorResponse(w, r, http.StatusConflict, message)
}
func (app *Application) rateLimitExceededResponse(w http.ResponseWriter, r *http.Request) {
	message := "rate limit exceeded"
	app.errorResponse(w, r, http.StatusTooManyRequests, message)
}

func (app *Application) invalidCredentialsResponse(w http.ResponseWriter, r *http.Request) {
	message := "invalid authentication credentials"
	app.errorResponse(w, r, http.StatusUnauthorized, message)
}

func (app *Application) invalidAuthenticationTokenResponse(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("WWW-Authenticate", "Bearer")
	message := "Access denied, kindly login again!"
	app.errorResponse(w, r, http.StatusUnauthorized, message)
}
func (app *Application) authenticationRequiredResponse(w http.ResponseWriter, r *http.Request) {
	message := "you must be authenticated to access this resource"
	app.errorResponse(w, r, http.StatusUnauthorized, message)
}
func (app *Application) inactiveAccountResponse(w http.ResponseWriter, r *http.Request) {
	message := "your user account must be activated to access this resource"
	app.errorResponse(w, r, http.StatusForbidden, message)
}
func (app *Application) NotPermittedResponse(w http.ResponseWriter, r *http.Request) {
	message := "your user account doesn't have the necessary permissions to access this resource"
	app.errorResponse(w, r, http.StatusForbidden, message)
}

func (app *Application) NotYetSet(w http.ResponseWriter, r *http.Request) {
	message := "the requested resource has not been set"
	//i have set 380 to not set!
	app.errorResponse(w, r, 380, message)
}

func (app *Application) paymentRequiredResponse(w http.ResponseWriter, r *http.Request) {
	message := "an active sync subscription is required for this resource"
	app.errorResponse(w, r, http.StatusPaymentRequired, message)
}
