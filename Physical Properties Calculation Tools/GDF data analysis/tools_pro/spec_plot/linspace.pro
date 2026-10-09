
;============================================================
;
; :Description:
;    Describe the procedure.
;
; :Params:
;    start  : 시작 값
;    final  : 끝 값
;    n      : n 등분, 또는 n 씩 증감.
;
;
; :Keywords:
;    step   : boolean. 1일 경우 n은 증감.
;    double
;
;
; :Author: DaeKyu Shin
;          Department of Astronomy and Space Science
;          Chungbuk National University
;          Cheongju 361-763, South Korea
;
; :E_mail: tlseorb0111@naver.com
;
; :Last Modited: 2015. 8. 4
;
;============================================================
function linspace, start, final, n, step=step, double=double

    if start gt final then rev=1 else rev=0

    if rev eq 0 then begin

        st = start
        fi = final

    endif else begin

        st = final
        fi = start

    endelse



    if keyword_set(double) then begin
        fi = double(fi)
        st = double(st)
    endif

    if ~keyword_set(step) then begin


        catch, err
        if err ne 0 then begin
            ;!error_state.MSG 가 HISTOGRAM: Illegal binsize or max/min.일 경우
            ; or 강제로 err 발생시킬 경우
            fi = double(fi)
            catch, /cancel
        endif



        !null = histogram([st, fi], nbins=n, loc=loc)


        ; loc, fi가 정수형일때 loc[-1]과 fi가 같지 않을경우
        ; 일부로 err를 발생시켜 fi를 double으로 만든다.
        ; 다음과 같은경우 loc[-1]과 fi가 같지 않다.
        ; !null = histogram([0, 10], nbin=4, loc=loc)
        ; print, loc[-1]
        sz = size(loc, /type)
        if sz le 3 or sz ge 12 then begin
            if fi ne loc[-1] then begin
                ; error 발생
                a = [1]
                a[10] = 10
            endif
        endif

        ; 어떤 상황에서는 마지막 자리수가 틀릴때가있네?
        ; histogram([0, 365d], nbin=2750, loc=loc)
        ; loc[-1]
        if loc[-1] ne fi then loc[-1] = fi

        if rev then loc = reverse(loc)
        return, loc

    endif else begin


        loc = [st:fi:n]

        if rev then begin
            loc = reverse(loc)
            if loc[0] ne fi then loc += (fi-loc[0])
        endif

        return, loc


    endelse

end

