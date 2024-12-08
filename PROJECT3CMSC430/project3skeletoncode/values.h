typedef char* CharPtr;

enum Operators {
    ADD,
    SUBTRACT,
    MULTIPLY,
    DIVIDE,
    MOD,
    EXP,
    AND,
    OR,
    NOT,
    NEG
};

// Adding ErrorType enumeration for error handling, renamed to avoid conflict
enum ErrorType {
    SYNTAX_ERROR,
    RUNTIME_ERROR,
    UNDECLARED_ERROR
};

double evaluateArithmetic(double left, Operators operator_, double right);
double evaluateRelational(double left, Operators operator_, double right);

