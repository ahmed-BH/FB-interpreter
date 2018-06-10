/*--------------------------------------------------------------------
 * 
 * call math function of <cmath> lib
 *
 *------------------------------------------------------------------*/
return_t built_in_func(char* func_name, func_args args)
{
    return_t to_return;
    if(string(func_name) == "cos")
    {
        if(args.size != 1)
        {
            to_return.error = "'cos' needs '1' argument  but found '" + to_string(args.size) + "'";
            return to_return;
        }
        else
        {
            to_return.result = cos(args.f_args[0]);
            to_return.error  = "";
            return to_return;
        }
    }
    else if(string(func_name) == "acos")
    {
        if(args.size != 1)
        {
            to_return.error = "'acos' needs '1' argument  but found '" + to_string(args.size) + "'";
            return to_return;
        }
        else
        {
            to_return.result = acos(args.f_args[0]);
            to_return.error  = "";
            return to_return;
        }
    }
    else if(string(func_name) == "sin")
    {
        if(args.size != 1)
        {
            to_return.error = "'sin' needs '1' argument  but found '" + to_string(args.size) + "'";
            return to_return;
        }
        else
        {
            to_return.result = sin(args.f_args[0]);
            to_return.error  = "";
            return to_return;
        }
    }
    else if(string(func_name) == "asin")
    {
        if(args.size != 1)
        {
            to_return.error = "'asin' needs '1' argument  but found '" + to_string(args.size) + "'";
            return to_return;
        }
        else
        {
            to_return.result = asin(args.f_args[0]);
            to_return.error  = "";
            return to_return;
        }
    }
    else if(string(func_name) == "tan")
    {
        if(args.size != 1)
        {
            to_return.error = "'tan' needs '1' argument  but found '" + to_string(args.size) + "'";
            return to_return;
        }
        else
        {
            to_return.result = tan(args.f_args[0]);
            to_return.error  = "";
            return to_return;
        }
    }
    else if(string(func_name) == "atan")
    {
        if(args.size != 1)
        {
            to_return.error = "'atan' needs '1' argument  but found '" + to_string(args.size) + "'";
            return to_return;
        }
        else
        {
            to_return.result = atan(args.f_args[0]);
            to_return.error  = "";
            return to_return;
        }
    }
    else if(string(func_name) == "atan2")
    {
        if(args.size != 2)
        {
            to_return.error = "'atan2' needs '2' argument  but found '" + to_string(args.size) + "'";
            return to_return;
        }
        else
        {
            to_return.result = atan2(args.f_args[0], args.f_args[1]);
            to_return.error  = "";
            return to_return;
        }
    }
    else if(string(func_name) == "exp")
    {
        if(args.size != 1)
        {
            to_return.error = "'exp' needs '1' argument  but found '" + to_string(args.size) + "'";
            return to_return;
        }
        else
        {
            to_return.result = exp(args.f_args[0]);
            to_return.error  = "";
            return to_return;
        }
    }
    else if(string(func_name) == "log")
    {
        if(args.size != 1)
        {
            to_return.error = "'log' needs '1' argument  but found '" + to_string(args.size) + "'";
            return to_return;
        }
        else
        {
            to_return.result = log(args.f_args[0]);
            to_return.error  = "";
            return to_return;
        }
    }
    else if(string(func_name) == "fmax" || string(func_name) == "max")
    {
        if(args.size >= 2 && args.size < MAX_ARGS)
        {
            to_return.result = fmax(args.f_args[0], args.f_args[1]);
            for(int i = 2; i < args.size; i++)
            {
                to_return.result = fmax(to_return.result, args.f_args[i]);
            }
            to_return.error  = "";
            return to_return;
        }
        else if( args.size == 1)
        {
            to_return.result = args.f_args[0];
            to_return.error  = "";
            return to_return;
        }
        else
        {
            to_return.error  = "'"+string(func_name)+"'"+" needs '1.."+to_string(MAX_ARGS)+"' arguments but found '" + to_string(args.size) + "'";
            return to_return;
        }
    }
    else if(string(func_name) == "fmin" || string(func_name) == "min")
    {
        if(args.size >= 2 && args.size < MAX_ARGS)
        {
            to_return.result = fmin(args.f_args[0], args.f_args[1]);
            for(int i = 2; i < args.size; i++)
            {
                to_return.result = fmin(to_return.result, args.f_args[i]);
            }
            to_return.error  = "";
            return to_return;
        }
        else if( args.size == 1)
        {
            to_return.result = args.f_args[0];
            to_return.error  = "";
            return to_return;
        }
        else
        {
            to_return.error  = "'"+string(func_name)+"'"+" needs '1.."+to_string(MAX_ARGS)+"' arguments but found '" + to_string(args.size) + "'";
            return to_return;
        }
    }
    else if(string(func_name) == "abs")
    {
        if(args.size != 1)
        {
            to_return.error = "'abs' needs '1' argument  but found '" + to_string(args.size) + "'";
            return to_return;
        }
        else
        {
            to_return.result = abs(args.f_args[0]);
            to_return.error  = "";
            return to_return;
        }
    }
    else
    {
        to_return.error = "call to unknown function '" + string(func_name) + "'" ;
        return to_return;
    }
}