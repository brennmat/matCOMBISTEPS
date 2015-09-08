function num = matCS_menu (t, varargin)

% function num = matCS_menu (t, varargin)
%
% This function is similar to the standard "menu (...)" function, with the exception that an "(X) Exit" entry is appended at the end (the corresponding return value is num = 0). For more information, see the standard menu function.

fflush (stdout);

## Don't send the menu through the pager since doing that can cause
## major confusion.

save_page_screen_output = page_screen_output ();

unwind_protect

  page_screen_output (0);

  if (! isempty (t))
    disp (t);
    printf ("\n");
  endif

  nopt = nargin - 1;

  while (1)
    for i = 1:nopt
      printf ("  [%2d] ", i);
      disp (varargin{i});
    endfor
    disp ("  [ X] EXIT");
    printf ("\n");
    s = input ("Your choice: ", "s");
    if strcmp(upper(s),"X")
	num = 0;
    else
	eval (sprintf ("num = %s;", s), "num = [];");
    end
    if (! isscalar (num) || num < 0 || num > nopt)
      printf ("\nerror: input invalid or out of range\n\n");
    else
      break;
    endif
  endwhile

unwind_protect_cleanup

  page_screen_output (save_page_screen_output);

end_unwind_protect

endfunction
