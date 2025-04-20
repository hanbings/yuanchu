///|
fn main {
  let code =
    #| ++++++++++             # cell[0] = 10
    #| [                      # loop 10 times
    #|   >+++++++             # cell[1] += 7 * 10 = 70
    #|   >++++++++++          # cell[2] += 10 * 10 = 100
    #|   >+++                 # cell[3] += 3 * 10 = 30
    #|   >+                   # cell[4] += 1 * 10 = 10
    #|   <<<<-                # back to cell[0], decrement
    #| ]
    #| >++.                   # print 'H' (cell[1] = 72)
    #| >+.                    # print 'e' (cell[2] = 101)
    #| +++++++.               # print 'l' (cell[2] = 108)
    #| .                      # print 'l'
    #| +++.                   # print 'o' (111)
    #| >++.                   # print ' ' (cell[3] = 32)
    #| <<+++++++++++++++.     # print 'W' (cell[1] = 87)
    #| >.                     # print 'o' (cell[2] = 111)
    #| +++.                   # print 'r' (114)
    #| ------.                # print 'l' (108)
    #| --------.              # print 'd' (100)
    #| >+.                    # print '!' (cell[3] = 33)
    #| >.                     # print newline (cell[4] = 10)
  let token = @lib.lex(code)
  let ast = @lib.parse(token)
  @lib.run(ast)
}
