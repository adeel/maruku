
*** Parameters: ***
require 'maruku/ext/math'
{:math_numbered => ['\\['], :html_math_engine => 'itex2mml', :html_math_generate_ids => true}
*** Markdown input: ***

\[
	\alpha
\]

\begin{equation}
	\alpha
\end{equation}

\begin{equation} \beta
\end{equation}


\begin{equation} \gamma \end{equation}
*** Output of inspect ***
md_el(:document,[
	md_el(:equation,[],{:label=>"eq1",:math=>"\n\t\\alpha\n\n",:num=>1},[]),
	md_el(:equation,[],{:label=>nil,:math=>"\n\t\\alpha\n\n",:num=>nil},[]),
	md_el(:equation,[],{:label=>nil,:math=>" \\beta\n\n",:num=>nil},[]),
	md_el(:equation,[],{:label=>nil,:math=>" \\gamma ",:num=>nil},[])
],{},[])
*** Output of to_html ***
<div class="maruku-equation" id="eq:eq1"><span class="maruku-eq-number">(1)</span><math xmlns="http://www.w3.org/1998/Math/MathML" display="block"  id="mathml_8a44f7002f8ded0bf70078a7e04511453c3470a2_1" class="maruku-mathml"><semantics><mrow><mi>α</mi></mrow><annotation encoding="application/x-tex">
	\alpha

</annotation></semantics></math></div><div class="maruku-equation"><math xmlns="http://www.w3.org/1998/Math/MathML" display="block" id="mathml_8a44f7002f8ded0bf70078a7e04511453c3470a2_2" class="maruku-mathml"><semantics><mrow><mi>α</mi></mrow><annotation encoding="application/x-tex">
	\alpha

</annotation></semantics></math></div><div class="maruku-equation"><math xmlns="http://www.w3.org/1998/Math/MathML" display="block" id="mathml_8a44f7002f8ded0bf70078a7e04511453c3470a2_3" class="maruku-mathml"><semantics><mrow><mi>β</mi></mrow><annotation encoding="application/x-tex"> \beta

</annotation></semantics></math></div><div class="maruku-equation"><math xmlns="http://www.w3.org/1998/Math/MathML" display="block" id="mathml_8a44f7002f8ded0bf70078a7e04511453c3470a2_4" class="maruku-mathml"><semantics><mrow><mi>γ</mi></mrow><annotation encoding="application/x-tex"> \gamma </annotation></semantics></math></div>
*** Output of to_latex ***
\begin{equation}
\alpha
\label{eq1}\end{equation}
\begin{displaymath}
\alpha
\end{displaymath}
\begin{displaymath}
\beta
\end{displaymath}
\begin{displaymath}
\gamma
\end{displaymath}
*** Output of to_md ***

*** Output of to_s ***

