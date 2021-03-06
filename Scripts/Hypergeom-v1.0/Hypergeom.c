/*
 * This file was generated automatically by xsubpp version 1.9508 from the
 * contents of Hypergeom.xs. Do not edit this file, edit Hypergeom.xs instead.
 *
 *	ANY CHANGES MADE HERE WILL BE LOST!
 *
 */

#line 1 "Hypergeom.xs"
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "hypergeom/hypergeom.h"

#include "const-c.inc"

#line 21 "Hypergeom.c"

/* INCLUDE:  Including 'const-xs.inc' from 'Hypergeom.xs' */


XS(XS_Hypergeom_constant); /* prototype to pass -Wmissing-prototypes */
XS(XS_Hypergeom_constant)
{
    dXSARGS;
    if (items != 1)
	Perl_croak(aTHX_ "Usage: Hypergeom::constant(sv)");
    SP -= items;
    {
#line 4 "const-xs.inc"
#ifdef dXSTARG
	dXSTARG; /* Faster if we have it.  */
#else
	dTARGET;
#endif
	STRLEN		len;
        int		type;
	/* IV		iv;	Uncomment this if you need to return IVs */
	/* NV		nv;	Uncomment this if you need to return NVs */
	/* const char	*pv;	Uncomment this if you need to return PVs */
#line 45 "Hypergeom.c"
	SV *	sv = ST(0);
	const char *	s = SvPV(sv, len);
#line 18 "const-xs.inc"
	type = constant(aTHX_ s, len);
      /* Return 1 or 2 items. First is error message, or undef if no error.
           Second, if present, is found value */
        switch (type) {
        case PERL_constant_NOTFOUND:
          sv = sv_2mortal(newSVpvf("%s is not a valid Hypergeom macro", s));
          PUSHs(sv);
          break;
        case PERL_constant_NOTDEF:
          sv = sv_2mortal(newSVpvf(
	    "Your vendor has not defined Hypergeom macro %s, used", s));
          PUSHs(sv);
          break;
	/* Uncomment this if you need to return IVs
        case PERL_constant_ISIV:
          EXTEND(SP, 1);
          PUSHs(&PL_sv_undef);
          PUSHi(iv);
          break; */
	/* Uncomment this if you need to return NOs
        case PERL_constant_ISNO:
          EXTEND(SP, 1);
          PUSHs(&PL_sv_undef);
          PUSHs(&PL_sv_no);
          break; */
	/* Uncomment this if you need to return NVs
        case PERL_constant_ISNV:
          EXTEND(SP, 1);
          PUSHs(&PL_sv_undef);
          PUSHn(nv);
          break; */
	/* Uncomment this if you need to return PVs
        case PERL_constant_ISPV:
          EXTEND(SP, 1);
          PUSHs(&PL_sv_undef);
          PUSHp(pv, strlen(pv));
          break; */
	/* Uncomment this if you need to return PVNs
        case PERL_constant_ISPVN:
          EXTEND(SP, 1);
          PUSHs(&PL_sv_undef);
          PUSHp(pv, iv);
          break; */
	/* Uncomment this if you need to return SVs
        case PERL_constant_ISSV:
          EXTEND(SP, 1);
          PUSHs(&PL_sv_undef);
          PUSHs(sv);
          break; */
	/* Uncomment this if you need to return UNDEFs
        case PERL_constant_ISUNDEF:
          break; */
	/* Uncomment this if you need to return UVs
        case PERL_constant_ISUV:
          EXTEND(SP, 1);
          PUSHs(&PL_sv_undef);
          PUSHu((UV)iv);
          break; */
	/* Uncomment this if you need to return YESs
        case PERL_constant_ISYES:
          EXTEND(SP, 1);
          PUSHs(&PL_sv_undef);
          PUSHs(&PL_sv_yes);
          break; */
        default:
          sv = sv_2mortal(newSVpvf(
	    "Unexpected return type %d while processing Hypergeom macro %s, used",
               type, s));
          PUSHs(sv);
        }
#line 119 "Hypergeom.c"
	PUTBACK;
	return;
    }
}


/* INCLUDE: Returning to 'Hypergeom.xs' from 'const-xs.inc' */


XS(XS_Hypergeom_cumhyper); /* prototype to pass -Wmissing-prototypes */
XS(XS_Hypergeom_cumhyper)
{
    dXSARGS;
    if (items != 4)
	Perl_croak(aTHX_ "Usage: Hypergeom::cumhyper(i, s1, s2, N)");
    {
	int	i = (int)SvIV(ST(0));
	int	s1 = (int)SvIV(ST(1));
	int	s2 = (int)SvIV(ST(2));
	int	N = (int)SvIV(ST(3));
	double	RETVAL;
	dXSTARG;

	RETVAL = cumhyper(i, s1, s2, N);
	XSprePUSH; PUSHn((double)RETVAL);
    }
    XSRETURN(1);
}


XS(XS_Hypergeom_lcumhyper); /* prototype to pass -Wmissing-prototypes */
XS(XS_Hypergeom_lcumhyper)
{
    dXSARGS;
    if (items != 4)
	Perl_croak(aTHX_ "Usage: Hypergeom::lcumhyper(i, s1, s2, N)");
    {
	int	i = (int)SvIV(ST(0));
	int	s1 = (int)SvIV(ST(1));
	int	s2 = (int)SvIV(ST(2));
	int	N = (int)SvIV(ST(3));
	double	RETVAL;
	dXSTARG;

	RETVAL = lcumhyper(i, s1, s2, N);
	XSprePUSH; PUSHn((double)RETVAL);
    }
    XSRETURN(1);
}


XS(XS_Hypergeom_cumbino); /* prototype to pass -Wmissing-prototypes */
XS(XS_Hypergeom_cumbino)
{
    dXSARGS;
    if (items != 3)
	Perl_croak(aTHX_ "Usage: Hypergeom::cumbino(k, N, p)");
    {
	int	k = (int)SvIV(ST(0));
	int	N = (int)SvIV(ST(1));
	double	p = (double)SvNV(ST(2));
	double	RETVAL;
	dXSTARG;

	RETVAL = cumbino(k, N, p);
	XSprePUSH; PUSHn((double)RETVAL);
    }
    XSRETURN(1);
}


XS(XS_Hypergeom_bino); /* prototype to pass -Wmissing-prototypes */
XS(XS_Hypergeom_bino)
{
    dXSARGS;
    if (items != 3)
	Perl_croak(aTHX_ "Usage: Hypergeom::bino(x, N, p)");
    {
	int	x = (int)SvIV(ST(0));
	int	N = (int)SvIV(ST(1));
	double	p = (double)SvNV(ST(2));
	double	RETVAL;
	dXSTARG;

	RETVAL = bino(x, N, p);
	XSprePUSH; PUSHn((double)RETVAL);
    }
    XSRETURN(1);
}

#ifdef __cplusplus
extern "C"
#endif
XS(boot_Hypergeom); /* prototype to pass -Wmissing-prototypes */
XS(boot_Hypergeom)
{
    dXSARGS;
    char* file = __FILE__;

    XS_VERSION_BOOTCHECK ;

        newXS("Hypergeom::constant", XS_Hypergeom_constant, file);
        newXS("Hypergeom::cumhyper", XS_Hypergeom_cumhyper, file);
        newXS("Hypergeom::lcumhyper", XS_Hypergeom_lcumhyper, file);
        newXS("Hypergeom::cumbino", XS_Hypergeom_cumbino, file);
        newXS("Hypergeom::bino", XS_Hypergeom_bino, file);
    XSRETURN_YES;
}

