package transferofcare;

import cucumber.api.PendingException;
import cucumber.api.java.en.Given;
import cucumber.api.java.en.When;

public class ParserErrorsStepDefinitions {
	
	@Given("^an input document which (.*)$")
	public void an_input_document_with_these_characteristics(String characteristics) {
	    throw new PendingException();
	}
	
	@When("^the ciao-parser attempts to process the document$")
    public void the_ciao_parser_attempts_to_process_the_document() {
        throw new PendingException();
    }
}
