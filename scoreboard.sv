class Scoreboard;
    bit [7:0] ref_queue[$]; // queue reference model

    function void write(bit [7:0] data);
        ref_queue.push_back(data);
    endfunction

    function bit [7:0] read();
        if (ref_queue.size() > 0)
            return ref_queue.pop_front();
        else // underflow case 
            return 'X; 
    endfunction

    function int size();
        return ref_queue.size();
    endfunction
endclass