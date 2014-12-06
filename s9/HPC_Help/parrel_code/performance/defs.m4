m4_divert(-1)
m4_changequote({,})

#----------------- Custom definitions ----------------

m4_dnl !!!The new-line char between "HI-UX/MPP" and "," should be preserved!!!
m4_ifelse(m4_esyscmd(/bin/uname), HI-UX/MPP
, {
  m4_define({_SR2201_}, 1)
  m4_define({_OPS_}, 100.0)
}, {
  m4_define({_OPS_}, 10.0)
})

#----------------------------------------------------------------------------
# Macros for FORTRAN do-loop unrolling.
#
#
# Developed at the Research and Development Center for Parallel Software,
# Institute of Software by:
#
#		     Linbo Zhang (zlb@lsec.cc.ac.cn)
#
#	State-key Laboratory of Scientific and Engineering Computing
#
#	      Institute of Computational Mathematics and
#		    Scientific/Engineering Computing
#
#		      Chinese Academy of Sciences
#
# Last updated: 5 Oct, 1996. All rights reserved.
#------------------------------------------------------------------------------

# ...........................................................................
# 			General Purpose Utilities
# ...........................................................................

#m4_ifdef({__gnu__}, {}, {m4_dnl
#    m4_errprint({Error: this file must be processed using GNU m4 with -P option
#    }){}m4_m4exit
#})

###
### ***** m4_forloop(dovar, start, end, loopbody) *****
###

m4_define( {m4_forloop},
  {m4_pushdef({$1},{$2})_m4_forloop({$1}, {$2}, {$3}, {$4})m4_popdef({$1})})

m4_define( {_m4_forloop},
 {m4_ifelse( m4_eval($1>$3),1,{},
   {$4{}m4_define({$1},m4_incr($1))_m4_forloop( {$1}, {$2}, {$3}, {$4})})})

###
### ***** m4_foreach(x, (item_1, item_2, ..., item_n), stmt) *****
###

#m4_define({m4_foreach}, {m4_pushdef({$1}, {})_m4_foreach({$1}, {$2}, {$3})m4_popdef({$1})})
#m4_define({_m4_arg1}, {$1})
#m4_define({_m4_foreach},
#        {m4_ifelse({$2}, {()}, ,
#                {m4_define({$1}, _m4_arg1$2)$3{}_m4_foreach({$1}, (m4_shift$2), {$3})})})

###
### ***** m4_max(number_1, number_2, ..., number_n) *****
###

m4_define({m4_max},
          {m4_ifelse($#, 2, {m4_ifelse(m4_eval($1>$2), 1, $1, $2)},
                            {m4_max($1, {m4_max(m4_shift($@))} )} )})

# ...........................................................................
# 				End of Utilities
# ...........................................................................

###
### m4_inner_most_dodepth is used to control compiler-dependent directives
### applied to the inner most do loop.
###

m4_define({m4_inner_most_dodepth}, 0)

m4_define({m4_compiler_directives}, {
    m4_ifelse(m4_dodepth, m4_inner_most_dodepth, {
m4_ifdef({_SR2201_},{*VOPTION indep})
    })
})

###
### ***** m4_begin_expansion, m4_end_expansion
### All macros defined below should be surrounded by:
### 	m4_begin_expansion
###	... ...
###	m4_end_expansion
### otherwise the post processor "m4post" will not work correctly.
###
### The outmost "m4_do" command will implicitly inserts "m4_begin_expansion"
### at start and "m4_end_expansion" at the end.
###

m4_define({m4_expansion_flag}, 0)

m4_define({m4_begin_expansion}, {{}m4_dnl
    m4_ifelse(m4_expansion_flag, 0, {
	*m4: start expansion
	m4_define({m4_expansion_flag}, 1)
    })
})

m4_define({m4_end_expansion}, {{}m4_dnl
    m4_ifelse(m4_expansion_flag, 1, {
	*m4: end expansion
	m4_define({m4_expansion_flag}, 0)
    })
})

###
### ***** m4_do( dovar, start, end, inc, unroll, {dobody}) *****
###
### Fortran do-loop expansion.
###

m4_define({m4_do}, {
    m4_ifelse($#, 6, {}, {
        m4_errprint({m4_do}: Incorrect number of arguments (file="m4___file__"   line=m4___line__)
        ){}m4_m4exit
    })
{}m4_dnl ************** Mark start of expansion
    m4_ifelse(m4_dodepth, 0, {
	m4_ifelse(m4_expansion_flag, 1, {}, {m4_begin_expansion})
    })
    m4_do_init($@)
{}m4_dnl ************** Pre loop ($1)
    m4_ifelse($5, 1, {}, {
       m4_do_pre($@)
       $6
       enddo
    })
{}m4_dnl ************** Main loop ($1)
    m4_do_main($@)
    $6
    enddo
    m4_define({m4_dodepth}, m4_decr(m4_dodepth))
{}m4_dnl ************** Mark end of expanded text
    m4_ifelse(m4_dodepth,0, {m4_end_expansion})
})

m4_define({m4_do_init}, {{}m4_dnl
    m4_define({m4_dodepth}, m4_incr(m4_dodepth))
    m4_define({m4_do_$1_inc}, {$4})
})

m4_define({m4_do_pre}, {
    m4_define({m4_unroll_$1_end}, 0)
    m4_ifelse($5, 1, {}, {
        m4_pushdef({m4_itmp$1})
	m4_define({m4_itmp$1},
          m4_ifelse(
             $4, 1,
           	{ m4_ifelse($2,1, {mod($3,$5)}, {$2-1+mod($3-($2-1),$5)}) },
             $4, -1,
                { $2 - (mod( ($2-($3)) + 1, $5)-1) },
m4_dnl       else
                { $2 + ($4)*(mod( ($3-($2))/($4) + 1, $5)-1) } m4_dnl
          ) )
        m4_ifelse($4, 1,  {itmp$1=min($3, m4_itmp$1)},
                  $4, -1, {itmp$1=max($3, m4_itmp$1)},
			  {if ( $4.gt.0) then
	   	              itmp$1=min($3, m4_itmp$1)
	                   else
		              itmp$1=max($3, m4_itmp$1)
	                   endif}
        )
        m4_popdef({m4_itmp$1})

*m4 - Clean-up loop on $1
	m4_ifelse($4,1, {
	    do $1=$2,itmp$1
	}, {
	    do $1=$2,itmp$1,$4
	})
    })
})

m4_define({m4_do_main}, {
    m4_define({m4_unroll_$1_end}, m4_decr($5))
*m4 - Unrolled loop on $1
    m4_compiler_directives
    m4_ifelse($5, 1,
	{
	    m4_ifelse($4,1,
		{
                    do $1=$2,$3
                },
	 	{
	 	    do $1=$2, $3, ($4)
	 	}
	    )
	},
	{
	    m4_ifelse($4,1, {
	                        do $1=max($2, itmp$1 + ($4)), $3, $5
	                    },
                      $4,-1,{
                                do $1=min($2, itmp$1 + ($4)), $3, -$5
                            },
			    {if ( $4.gt.0) then
		                itmp$1=max($2, itmp$1 + ($4) )
	    	             else
		                itmp$1=min($2, itmp$1 + ($4) )
	    	             endif
	 	             do $1=itmp$1, $3, ($5)*($4)}
	    )
	}
    )
})

###
### ***** m4_expand(dovar1, [dovar2,...,] body) *****
###
### "m4_expand" should be used within corresponding "m4_do" bodies.
###
### "m4_pexpand(dovar1, start1, end1, inc1, dovar2, start2, end2, inc2, ..., body)"
### should be used instead if outside "m4_do".
###
### Warning: newlines will be automatically inserted before and after "body",
###          inserting a '&' at the beginning of "body" means that all lines
###	     in the expansion text are FORTRAN continuation lines.
###

m4_define({m4_pexpand_one_level}, {{}m4_dnl
    m4_ifelse($#, 5,{}, {{}m4_dnl
        m4_errprint({m4_pexpand_one_level}: Incorrect number of arguments (File="m4___file__"   line=m4___line__)
        ){}m4_m4exit
    }){}m4_dnl
    m4_ifelse(m4_expansion_flag, 1, {}, {m4_begin_expansion})
    m4_pushdef({$1}){}m4_dnl
    m4_ifelse(
      $4, 1,
         {m4_define({$1}, {{$1}m4_ifelse(_$1_, 0, {}, {+_$1_})})},
      $4,-1,
         {m4_define({$1}, {{$1}m4_ifelse(_$1_, 0, {}, {-_$1_})})},
      m4_dnl else
         {m4_define({$1}, {{$1}m4_ifelse(_$1_, 0, {}, +($4)*_$1_)})}
    )
    m4_forloop( {_$1_}, {$2}, {$3}, {
        $5
    })
    m4_popdef({$1}){}m4_dnl
})

m4_define({m4_expand_one_level}, {{}m4_dnl
    m4_ifelse($#, 2,{}, {{}m4_dnl
        m4_errprint({m4_expand_one_level}: Incorrect number of arguments (File="m4___file__"   line=m4___line__)
        ){}m4_m4exit
    }){}m4_dnl
    m4_pexpand_one_level($1, 0, m4_unroll_$1_end, m4_do_$1_inc, {$2})
})

m4_define({m4_expand}, {
    m4_ifelse($#, 2, {m4_expand_one_level($@)},
                     {m4_expand_one_level($1,{m4_expand(m4_shift($@))})})
})

m4_define({m4_pexpand}, {
    m4_ifelse($#, 5, {m4_pexpand_one_level($@)},
                     {m4_pexpand_one_level($1, $2, $3, $4,
			{m4_pexpand(m4_shift(m4_shift(m4_shift(m4_shift($@)))))})})
})

###
### ***** m4_dodepth *****
###
### Stores current depth of nested do-loop expansion.
###

m4_define(m4_dodepth, 0)

###
### ***** m4_make_local(prefix, dovar1[, dovar2, ...])  *****
###
### Used to introduce scratch variables.
### For example, m4_make_local(t,{i},{j}) ==> t0_0, t0_1, t1_0, t1_1, ...
###

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  The following definition allows up to 8 nested expansions.		~
#???m4_define({m4_make_index},{{}m4_dnl					~
#???  m4_ifelse(							~
#???    $#, 1, _$1_,							~
#???    $#, 2, _$1_|_$2_,						~
#???    $#, 3, _$1_|_$2_|_$3_,						~
#???    $#, 4, _$1_|_$2_|_$3_|_$4_,					~
#???    $#, 5, _$1_|_$2_|_$3_|_$4_|_$5_,				~
#???    $#, 6, _$1_|_$2_|_$3_|_$4_|_$5_|_$6_,				~
#???    $#, 7, _$1_|_$2_|_$3_|_$4_|_$5_|_$6_|_$7_,			~
#???    $#, 8, _$1_|_$2_|_$3_|_$4_|_$5_|_$6_|_$7_|_$8_)})		~
#???  ){}m4_dnl								~
#???})									~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

m4_define({m4_make_index},
  {_$1_{}m4_ifelse($#, 1, {}, {|m4_make_index(m4_shift($@))})})

m4_define({m4_make_local}, {{}m4_dnl
  m4_ifdef({$1}, {
    m4_errprint(Error: $1 already defined (file="m4___file__"   line=m4___line__)
    ){}m4_m4exit
  }){}m4_dnl
  {$1}m4_make_index(m4_shift($@))})

###
### ***** m4_local(var, dovar1[, dovar2, ...]) *****
###
### is used to declare temperary variables which are to be
### expanded within do-loop expansions, e.g., m4_local(t, {i}, {j})
### declares the variable "t" to expand with "i" and "j".
###
### WARNING: Temperary variables should be explicitly undefined after
###          the do-loop expansion.
###

m4_define({m4_local}, {
    m4_define({$1}, m4_make_local({{$1}}, m4_shift($@)))
})

###
### ***** m4_texpand(var0, doloopvar, start, end, offset, {body})
### starts a triangular expansion.
###

m4_define({m4_texpand}, {{}m4_dnl
    m4_ifelse($#, 6,{}, {{}m4_dnl
        m4_errprint({m4_texpand}: Incorrect number of arguments (File="m4___file__"   line=m4___line__)
        ){}m4_m4exit
    }){}m4_dnl
    m4_ifelse(m4_unroll_$2_end, 0, {}, {
        m4_pushdef({$1}){}m4_dnl
	m4_ifelse(
	    m4_do_$2_inc, 1,
 	      {m4_define({$1},
		{{$2}m4_ifelse(m4_eval(_$1_+$5), 0, {},
		    {m4_ifelse(m4_eval(m4_eval(_$1_+$5)>0), 1,
			+m4_eval(_$1_+$5), m4_eval(_$1_+$5) ) })})},
	    m4_do_$2_inc,-1,
	      {m4_define({$1},
		{{$2}m4_ifelse(m4_eval(_$1_+$5), 0, {},
		    {m4_ifelse(m4_eval(m4_eval(_$1_+$5)<0), 1,
			+m4_eval(-(_$1_+$5)), -m4_eval(_$1_+$5) ) })})},
	    m4_dnl Otherwise
	      {m4_define({$1},
		{{$2}m4_ifelse(m4_eval(_$1_+$5), 0, {},
		    {m4_ifelse(m4_eval(m4_eval(_$1_+$5)>0), 1,
			+m4_eval(_$1_+$5), m4_eval(_$1_+$5) )*(m4_do_$1_inc) })})}
	)
	m4_forloop( {_$1_}, $3, $4, {
           $6
	})
	m4_popdef({$1}){}m4_dnl
    })
})

###
### ****** m4_do_with_incvar(dovar, start, end, inc, unroll,
###                          incvar, initvalue, inc, {dobody})
###
### ****** m4_do_with_2incvars(dovar, start, end, inc, unroll,
###                           incvar1, initvalue1, inc1,
###                           incvar2, initvalue2, inc2, {dobody})
###            ... ...
###
### Fortran do-loop expansion with an incremental variable (ix=ix+incx)
###

m4_define({m4_do_with_incvar}, {
    m4_ifelse($#, 9, {}, {
        m4_errprint({m4_do_with_incvar}: Incorrect number of arguments (file="m4___file__"   line=m4___line__)
        ){}m4_m4exit
    })
{}m4_dnl ************** Mark start of expansion
    m4_ifelse(m4_dodepth, 0, {
	m4_ifelse(m4_expansion_flag, 1, {}, {m4_begin_expansion})
    })
    m4_do_init($@)
{}m4_dnl ************** Pre loop ($1)
    $6{}0=$7
    m4_ifelse($5, 1, {}, {
	m4_do_pre($@)
	m4_local($6, $1)
	$9
	m4_undefine({$6})
	$6{}0=$6{}0+$8
	enddo
    })
{}m4_dnl ************** Main loop ($1)
    m4_do_main($@)
    m4_forloop({_$1_}, 1, m4_decr($5), {
	$6{}_$1_=$6{}m4_decr(_$1_)+$8
    })
    m4_local($6, $1)
    $9
    m4_undefine({$6})
    $6{}0=$6{}m4_decr($5)+$8
    enddo
    m4_define({m4_dodepth}, m4_decr(m4_dodepth))
{}m4_dnl ************** Mark end of expanded text
    m4_ifelse(m4_dodepth,0, {m4_end_expansion})
})

m4_define({m4_do_with_2incvars}, {
    m4_ifelse($#, 12, {}, {
        m4_errprint({m4_do_with_2incvars}: Incorrect number of arguments (file="m4___file__"   line=m4___line__)
        ){}m4_m4exit
    })
{}m4_dnl ************** Mark start of expansion
    m4_ifelse(m4_dodepth, 0, {
	m4_ifelse(m4_expansion_flag, 1, {}, {m4_begin_expansion})
    })
    m4_do_init($@)
{}m4_dnl ************** Pre loop ($1)
    $6{}0=$7
    $9{}0=$10
    m4_ifelse($5, 1, {}, {
	m4_do_pre($@)
	m4_local($6, $1)
	m4_local($9, $1)
	$12
	m4_undefine({$6})
	m4_undefine({$9})
	$6{}0=$6{}0+$8
	$9{}0=$9{}0+$11
	enddo
    })
{}m4_dnl ************** Main loop ($1)
    m4_do_main($@)
    m4_forloop({_$1_}, 1, m4_decr($5), {
	$6{}_$1_=$6{}m4_decr(_$1_)+$8
	$9{}_$1_=$9{}m4_decr(_$1_)+$11
    })
    m4_local($6, $1)
    m4_local($9, $1)
    $12
    m4_undefine({$6})
    m4_undefine({$9})
    $6{}0=$6{}m4_decr($5)+$8
    $9{}0=$9{}m4_decr($5)+$11
    enddo
    m4_define({m4_dodepth}, m4_decr(m4_dodepth))
{}m4_dnl ************** Mark end of expanded text
    m4_ifelse(m4_dodepth,0, {m4_end_expansion})
})

m4_define({m4_do_with_4incvars}, {
    m4_ifelse($#, 18, {}, {
        m4_errprint({m4_do_with_4incvars}: Incorrect number of arguments (file="m4___file__"   line=m4___line__)
        ){}m4_m4exit
    })
{}m4_dnl ************** Mark start of expansion
    m4_ifelse(m4_dodepth, 0, {
	m4_ifelse(m4_expansion_flag, 1, {}, {m4_begin_expansion})
    })
    m4_do_init($@)
{}m4_dnl ************** Pre loop ($1)
    $6{}0=$7
    $9{}0=$10
    $12{}0=$13
    $15{}0=$16
    m4_ifelse($5, 1, {}, {
	m4_do_pre($@)
	m4_local($6, $1)
	m4_local($9, $1)
	m4_local($12, $1)
	m4_local($15, $1)
	$18
	m4_undefine({$6})
	m4_undefine({$9})
	m4_undefine({$12})
	m4_undefine({$15})
	$6{}0=$6{}0+$8
	$9{}0=$9{}0+$11
	$12{}0=$12{}0+$14
	$15{}0=$15{}0+$17
	enddo
    })
{}m4_dnl ************** Main loop ($1)
    m4_do_main($@)
    m4_forloop({_$1_}, 1, m4_decr($5), {
	$6{}_$1_=$6{}m4_decr(_$1_)+$8
	$9{}_$1_=$9{}m4_decr(_$1_)+$11
	$12{}_$1_=$12{}m4_decr(_$1_)+$14
	$15{}_$1_=$15{}m4_decr(_$1_)+$17
    })
    m4_local($6, $1)
    m4_local($9, $1)
    m4_local($12, $1)
    m4_local($15, $1)
    $18
    m4_undefine({$6})
    m4_undefine({$9})
    m4_undefine({$12})
    m4_undefine({$15})
    $6{}0=$6{}m4_decr($5)+$8
    $9{}0=$9{}m4_decr($5)+$11
    $12{}0=$12{}m4_decr($5)+$14
    $15{}0=$15{}m4_decr($5)+$17
    enddo
    m4_define({m4_dodepth}, m4_decr(m4_dodepth))
{}m4_dnl ************** Mark end of expanded text
    m4_ifelse(m4_dodepth,0, {m4_end_expansion})
})

#m4_define({m4_incvar_init}, {
#   m4_ifelse(m4_unroll_$1_end, 0, {
#      m4_pexpand({$1}, 0, 0, {$2})
#   })
#})

m4_divert{}m4_dnl
