import { animated } from "@react-spring/web"
export function make(props, children) {
    return <animated.div {...props}> {children} </animated.div>
}