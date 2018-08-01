package uk.gov.hmcts.reform.sscscorbackend;

import static org.springframework.web.bind.annotation.RequestMethod.GET;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {
    @RequestMapping(value = "/hello", method = GET)
    public String helloActuator() {
        return "Hello Spring Boot branch";
    }
}
