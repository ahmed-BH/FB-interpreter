string str(char* lex)
{
	string tmp(lex);
	string res = "";
	for(int i=0; i<tmp.size(); i++)
	{
		if(tmp[i] != '"')
			res += tmp[i];
	}

	return res;
}

string str_mult(char* lex, int coef)
{
	string tmp = str(lex);
	string res = "";
	for(int i=0; i<coef; i++)
		res += tmp;

	return res;
}

