use <misc.scad>

// translate children
module linup(arr=undef)
{
    if($children>0)
    {
        for (i = [0 : $children-1])
        translate(arr[i]) children(i);
    }
}

module stack(dist=10, distances=undef, axis=[0,0,1])
{
    if($children>0)
    {
        if(dist == undef && distances != undef)
        {
            for (i = [0:len(distances)-1])
            {
                offset = v_sum(distances,i);
                translate(axis*offset)
                    child(i);
            }
        }
        else if(dist != undef && distances == undef)
        {
            for (i = [0 : $children-1])
                translate(axis*(dist*i))
                    children(i);
        }
    }
}

module orient(axis=[0,0,1], axis_ref=[0,0,1], roll=0)
{
    rotate(axis_ref==undef?0:_orient_angles(axis_ref))
    rotate(axis==undef?0:_orient_angles(axis))
    rotate(axis==undef?0:roll*axis)
    children();
}


function _orient_bounds(orient, size) =
    (_rotate_matrix(_orient_angles(orient)) * [size.x,size.y,size.z,1]);

function _orient_t(orient, align, size) =
    let(bounds = _orient_bounds(orient, size))
    (hadamard(align, [abs(bounds.x/2),abs(bounds.y/2),abs(bounds.z/2)]));

module size_align(size=[10,10,10], extra_size=[0,0,0], align=[0,0,0], extra_align=[0,0,0], orient=[0,0,1], orient_ref=[0,0,1], orient_roll=0)
{
    t = orient==undef?[0,0,0]:_orient_t(orient, align, size);
    /*t_ = orient_ref==undef?[0,0,0]:_orient_t(orient_ref, align, size);*/
    extra_t = (orient==undef||extra_size==undef)?[0,0,0]:_orient_t(orient, extra_align, extra_size);
    translate(t+extra_t)
    {
        orient(axis=orient, axis_ref=orient_ref, roll=orient_roll)
        {
            children();
        }
    }
}

module hull_pairwise()
{
    for (i= [1:1:$children-1])
    {
        hull()
        {
            children(i-1);
            children(i);
        }
    }
}

