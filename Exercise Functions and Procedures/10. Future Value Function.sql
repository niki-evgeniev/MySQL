CREATE FUNCTION ufn_calculate_future_value(arg_sum DECIMAL(19, 4), arg_yearly_interest_rate DOUBLE, arg_years INT)
    RETURNS DECIMAL(19, 4)
    DETERMINISTIC
BEGIN
    RETURN arg_sum * pow((1 + arg_yearly_interest_rate), arg_years);
END