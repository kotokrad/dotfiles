;; Macros

(fn augroup [name ...]
  `(do
     (nvim.ex.augroup ,(tostring name))
     (nvim.ex.autocmd_)
     ,...
     (nvim.ex.augroup :END)))

(fn autocmd [...]
  `(nvim.ex.autocmd ,...))

; (fn _: [name ...]
;   `((. nvim.ex ,(tostring name)) ,...))

(fn viml->fn [name]
  `(.. "lua require('" *module-name* "')['" ,(tostring name) "']()"))

(fn dbg [x]
  `(let [view# (require "aniseed.view")]
    (print (.. `,(tostring x) " => " (view#.serialise ,x)))
    ,x))

(fn dbg-call [x ...]
  `(do
     (let [a# (require "aniseed.core")]
       (a#.println ,...))
     (,x ,...)))

(fn each-pair [args ...]
  (let [[l# r# d#] args]
    `(let [a# (require "aniseed.core")
           data# ,d#]
       (for [i# 1 (a#.count data#) 2]
         (let [,l# (. data# i#)]
              ,r# (. data# (+ i# 1))
          ,...)))))

{:augroup augroup
 :autocmd autocmd
 :viml->fn viml->fn
 :dbg dbg
 :dbg-call dbg-call
 :each-pair each-pair}
