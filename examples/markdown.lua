local dashboard = Dashboard("Markdown Example");

-- HEADINGS
dashboard:push("# h1 heading");
dashboard:push("## h2 heading");
dashboard:push("### h3 heading");
dashboard:push("#### h4 heading");
dashboard:push("##### h5 heading");
dashboard:push("###### h6 heading");

dashboard:push("$a^2+b^2=c^2$");
dashboard:push("$$a^2+b^2=c^2$$");

-- URL
dashboard:push("## URL");
dashboard:push("[Text of the link](http://psr-inc.com)");

-- LISTS
dashboard:push("## Lists");
dashboard:push("### unordered");

dashboard:push("- unordered");
dashboard:push("* list");
dashboard:push("+ items");

dashboard:push("* unordered");
dashboard:push("  * list");
dashboard:push("  * items");
dashboard:push("    * in");
dashboard:push("    + an");
dashboard:push("  - hierarchy");

dashboard:push("### ordered");

dashboard:push("1. ordered");
dashboard:push("2. list");
dashboard:push("3. items");

dashboard:push("1. ordered");
dashboard:push("* list");
dashboard:push("* items");

dashboard:push("1. ordered");
dashboard:push("* list");
dashboard:push("  1. items");
dashboard:push("  * in");
dashboard:push("    1. an");
dashboard:push("  * hierarchy");

dashboard:push("### combination");

dashboard:push("* combination");
dashboard:push("* of");
dashboard:push("  1. unordered and");
dashboard:push("  * ordered");
dashboard:push("* list");

dashboard:push("### checklist");

dashboard:push("- [ ] some item");
dashboard:push("  - [ ] another item");
dashboard:push("- [x] some checked item");


dashboard:push("## Code Blocks");

dashboard:push("```cpp\n\
exp:aggregate_agents(BY_SUM()):save(\"filename\") \n\
```");

dashboard:push("## Inline code");

dashboard:push("some text `some inline code` some other text");

dashboard:push("## quotes");

dashboard:push("> Some quote");

dashboard:push("## bold");


dashboard:push("**bold text**");
dashboard:push("__bold text__");

dashboard:push("## italic");

dashboard:push("*italic text*");

dashboard:push("## emphasized");

dashboard:push("_emphasized text_");

dashboard:push("## strikethrough");

dashboard:push("~~striked through text~~");

dashboard:push("## horizontal line");

dashboard:push("---");

dashboard:push("## break line");

dashboard:push("New\r\nLine");

dashboard:push("## Images");

dashboard:push("![Image alt text](https://www.psr-inc.com/wp-content/themes/psrNew/images/logo.png)");

dashboard:push("## Tables");

dashboard:push(" A | B | C ");
dashboard:push("---|--:|:-:");
dashboard:push("aaa|bbb|ccc");

dashboard:push("\
 A | B | C  \
---|--:|:-: \
aaa|bbb|ccc \
");


dashboard:push("a | b | c | d | e | f");
dashboard:push(":-- |:-:|:-:|:-:|:-:|:-:");

dashboard:push("A. VERMELHA | 503.2 | 375.0 | 8.7 | 3.7 | 5.9");
dashboard:push("AIMORES | 140.6 | 109.6 | 34.3 | 7.8 | 28.8");
dashboard:push("BAIXO IGUACU | 232.4 | 257.0 | 0.0 | 0.0 | 0.0");
dashboard:push("CAPIVARA | 253.4 | 264.2 | 0.0 | 0.0 | 0.0");
dashboard:push("D. FRANCISCA | 73.2 | 21.1 | 3.6 | 0.2 | 0.5");
dashboard:push("EMBORCACAO | 72.2 | 112.5 | 9.7 | 12.4 | 25.1");
dashboard:push("FOZ CHAPECO | 223.6 | 275.9 | 0.0 | 0.0 | 0.0");
dashboard:push("FUNIL-GRANDE | 73.0 | 50.0 | 10.4 | 5.8 | 7.8");
dashboard:push("FURNAS | 174.6 | 139.9 | 9.3 | 7.9 | 12.7");
dashboard:push("ITA | 176.4 | 151.8 | 0.1 | 0.1 | 0.1");
dashboard:push("ITAIPU | 3062.8 | 2853.7 | 0.0 | 0.0 | 0.0");
dashboard:push("ITUMBIARA | 295.0 | 82.4 | 9.8 | 16.6 | 30.0");
dashboard:push("JIRAU | 3039.4 | 3336.5 | 5.4 | 5.2 | 26.2");
dashboard:push("JUPIA | 1989.4 | 2301.7 | 7.9 | 0.6 | 12.9");
dashboard:push("MACHADINHO | 130.0 | 120.3 | 0.3 | 0.1 | 0.1");
dashboard:push("MARIMBONDO | 395.2 | 372.8 | 8.7 | 11.8 | 30.7");
dashboard:push("MAUA | 38.6 | 80.5 | 7.4 | 9.7 | 33.3");
dashboard:push("P. COLOMBIA | 249.2 | 199.4 | 8.9 | 6.7 | 11.7");
dashboard:push("P. PRIMAVERA | 2337.2 | 2717.5 | 7.6 | 2.0 | 15.9");
dashboard:push("PEIXE ANGIC | 207.2 | 520.2 | 0.0 | 0.0 | 0.0");
dashboard:push("SAO SIMAO | 525.8 | 683.4 | 8.4 | 4.7 | 9.8");
dashboard:push("SERRA MESA | 110.2 | 436.5 | 0.0 | 0.0 | 0.0");
dashboard:push("SINOP | 243.6 | 282.9 | 2.3 | 3.6 | 5.0");
dashboard:push("TELES PIRES | 397.2 | 511.7 | 2.3 | 4.1 | 14.");


dashboard:save("markdown")